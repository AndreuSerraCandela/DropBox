/// <summary>
/// Codeunit Dropbox (ID 50006).
/// </summary>
Codeunit 7001136 Dropbox
{
    var
        get_metadata: Label '2/files/get_metadata';
        create_folder: Label '2/files/create_folder_v2';
        move_folder: Label '2/files/move_v2';
        sharefolder: Label '2/sharing/share_folder';
        list_folfer_members: Label '/2/sharing/list_folder_members';
        list_folder: Label '2/files/list_folder';
        list_folder_continue: Label '2/files/list_folder/continue';
        delete: Label '2/files/delete_v2';
        grant_type_authorization_code: Label 'authorization_code';
        grant_type_refresh_token: Label 'refresh_token';
        oauth2_token: Label 'oauth2/token';

        get_temporary_link: Label '2/files/get_temporary_link';
        Upload: Label '2/files/get_temporary_upload_link';
        JObjectPDFToMerge: JsonObject;
        JArrayPDFToMerge: JsonArray;
        JObjectPDF: JsonObject;

        JnodeEntryToken: JsonToken;
        JsonEntry: JsonObject;
        JnodeProertiesToken: JsonToken;
        JsonProperties: JsonObject;
        JnodevsignToken: JsonToken;
        Base64Txt: Text;
        origen: Text;
        root: Text;
        origenfinal: Text;
        tipofinal: Text;


    trigger OnRun()
    var

    begin



    end;

    //[ServiceEnabled]
    /// <summary>
    /// Token.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure Token(): Text
    var
        CompanyInfo: Record "Company Information";


    begin
        //-default-/public/authentication/versions/1/tickets
        // This code gets the ticket from Dropbox
        CompanyInfo.ChangeCompany('Malla Publicidad');
        CompanyInfo.GET();
        if CompanyInfo."Fecha Expiracion Token Dropbox" < CurrentDateTime then
            RefreshToken();
        Commit();
        CompanyInfo.GET();
        exit(CompanyInfo.GetTokenDropbox());
    end;

    procedure Carpetas(Carpeta: Text; Var Files: Record "Name/Value Buffer" temporary)
    var
        CompanyInfo: Record "Company Information";
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        Dropbox: Codeunit Dropbox;
        JTokO: JsonToken;
        JTok: JsonToken;
        JEntries: JsonArray;
        JEntry: JsonObject;
        JEntryToken: JsonToken;
        JEntryTokens: JsonToken;
        tag: Text;
        Cursor: Text;
        HasMore: Boolean;
        a: Integer;
    begin
        Files.DeleteAll();
        //https://api.dropboxapi.com/2/files/list_folder_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + list_folder;
        // {
        //     "include_deleted": false,
        //     "include_has_explicit_shared_members": false,
        //     "include_media_info": false,
        //     "include_mounted_folders": true,
        //     "include_non_downloadable_files": true,
        //     "path": "",
        //     "recursive": false
        // }
        Clear(Body);
        Body.add('include_deleted', false);
        Body.add('include_has_explicit_shared_members', false);
        Body.add('include_media_info', false);
        Body.add('include_mounted_folders', true);
        Body.add('include_non_downloadable_files', true);
        if Carpeta <> '' then
            Body.add('path', '/' + Carpeta)
        else
            Body.add('path', '');
        Body.add('recursive', false);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        If StatusInfo.Get('entries', JTok) Then begin
            JEntries := JTok.AsArray();
            foreach JEntryTokens in JEntries do begin
                JEntry := JEntryTokens.AsObject();
                If JEntry.Get('.tag', JEntryToken) Then begin
                    tag := JEntryToken.AsValue().AsText();
                end;
                // end;
                if JEntry.Get('name', JEntryToken) then begin
                    if tag = 'folder' then begin
                        Files.Init();
                        a += 1;
                        Files.ID := a;
                        Files.Name := JEntryToken.AsValue().AsText();
                        Files.Value := 'Carpeta';
                        Files.Insert();
                    end else begin
                        Files.Init();
                        a += 1;
                        Files.ID := a;
                        Files.Name := JEntryToken.AsValue().AsText();
                        Files.Value := '';
                        Files.Insert();
                    end;

                end;
            end;
        end;
        if StatusInfo.Get('cursor', JTok) then begin
            Cursor := JTok.AsValue().AsText();
        end;
        if StatusInfo.Get('has_more', JTok) then begin
            hasmore := JTok.AsValue().AsBoolean();
        end;
        If hasmore then
            repeat
                Clear(Body);
                Body.add('cursor', Cursor);
                Body.WriteTo(Json);
                Url := Inf."Url Api DropBox" + list_folder_continue;
                Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
                Clear(StatusInfo);
                StatusInfo.ReadFrom(Respuesta);
                StatusInfo.WriteTo(Json);
                //"entries": [
                // {
                //     ".tag": "folder",
                //     "name": "prueba",
                //     "path_lower": "/prueba",
                //     "path_display": "/prueba",
                //     "id": "id:W1FIDMoXTbgAAAAAAAAACA"
                // },
                //recuperar entries
                If StatusInfo.Get('entries', JTok) Then begin
                    JEntries := JTok.AsArray();
                    foreach JEntryTokens in JEntries do begin
                        JEntry := JEntryTokens.AsObject();
                        If JEntry.Get('.tag', JEntryToken) Then begin
                            tag := JEntryToken.AsValue().AsText();
                        end;
                        // end;
                        if JEntry.Get('name', JEntryToken) then begin

                            if tag = 'folder' then begin
                                Files.Init();
                                a += 1;
                                Files.ID := a;
                                Files.Name := JEntryToken.AsValue().AsText();
                                Files.Value := 'Carpeta';
                                Files.Insert();
                            end else begin
                                Files.Init();
                                a += 1;
                                Files.ID := a;
                                Files.Name := JEntryToken.AsValue().AsText();
                                Files.Value := '';
                                Files.Insert();
                            end;
                        end;
                    end;
                end;
                if StatusInfo.Get('cursor', JTok) then begin
                    Cursor := JTok.AsValue().AsText();
                end;
                if StatusInfo.Get('has_more', JTok) then begin
                    hasmore := JTok.AsValue().AsBoolean();
                end;

            until hasmore = false;
        //"entries": [
        // {
        //     ".tag": "folder",
        //     "name": "prueba",
        //     "path_lower": "/prueba",
        //     "path_display": "/prueba",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACA"
        // },
        // {
        //     ".tag": "folder",
        //     "name": "Homework",
        //     "path_lower": "/homework",
        //     "path_display": "/Homework",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACg"
        // },
        // {
        //     ".tag": "folder",
        //     "name": "Navision",
        //     "path_lower": "/navision",
        //     "path_display": "/Navision",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAAJg"
        // },  
    end;

    procedure ListFolder(
        Carpeta: Text; Accion: Option " ","Seleccionar","Anterior","Descargar Archivo","Mover","Crear Carpeta",Borrar,"Subir Archivo",Base64;
        Var Tipo: Text; Continuar: Boolean): Text
    var
        Dropbox: Codeunit Dropbox;

        Id: Text;
        tag: Text;
        Files: Record "Name/Value Buffer" temporary;
        PFiles: Page "Name/Value Lookup";
        UltimaBarra: Text;
        barra: Integer;
        Ventana: Page "Dialogo Dropbox";
        CarpetaDestino: Text;
        Cursor: Text;
        hasmore: Boolean;
        NVInStream: Instream;
        Filename: Text;
        Destino: Text;
        StatusInfo: JsonObject;
    begin
        if root = '' then
            root := Carpeta;
        Carpetas(Carpeta, Files);
        if Files.FindFirst() then begin
            PFiles.AddItem('..', 'Carpeta');
            repeat
                PFiles.AddItem(Files.Name, Files.Value);
            until Files.Next() = 0;
        end;
        Commit();
        PFiles.Navegar(root);
        if Accion = Accion::Mover then begin
            PFiles.Mover();
        end;
        If PFiles.RunModal() in [Action::LookupOk, Action::OK] then begin
            Files.Init();
            PFiles.GetNombre(Files.Name, Files.Value, Accion);
            if Files.Name = '-' then
                exit('-');
            tipo := Files.Value;
            if StrLen(root) = 0 then
                root := '/'
            else if Copystr(root, 1, 1) <> '/' then
                root := '/' + root;
            Case Files.Value Of
                'Carpeta':
                    begin
                        //Carpeta/Subcarpeta/Archivo
                        //Volver a la carpeta antertior
                        Case Accion Of
                            Accion::Seleccionar:
                                exit(Copystr(root, 2) + '/' + Files.Name);
                            Accion::"Crear Carpeta":
                                begin
                                    if not Continuar then
                                        exit(CreateFolder(Copystr(root, 2) + '/' + Files.Name))
                                    else
                                        CreateFolder(Copystr(root, 2) + '/' + Files.Name);
                                    exit(ListFolder(Copystr(root, 2), Accion, tipo, Continuar));

                                end;
                            Accion::Borrar:
                                begin
                                    if not continuar then
                                        exit(DeleteFolder(Copystr(root, 2) + '/' + Files.Name, false))
                                    else
                                        DeleteFolder(Copystr(root, 2) + '/' + Files.Name, false);
                                    exit(ListFolder(Copystr(root, 2), Accion, tipo, Continuar));
                                end;
                            Accion::"Subir Archivo":
                                begin
                                    // Ventana.SetTexto('Nombre Archivo');
                                    // Ventana.RunModal();
                                    // Ventana.GetTexto(Filename);
                                    UPLOADINTOSTREAM('Import', '', ' All Files (*.*)|*.*', Filename, NVInStream);
                                    If not Continuar then
                                        exit(UploadFileB64(Copystr(root, 2), NVInStream, Filename))
                                    else
                                        UploadFileB64(Copystr(root, 2), NVInStream, Filename);
                                    exit(ListFolder(Copystr(root, 2), Accion, tipo, Continuar));
                                end;
                            Accion::Mover:
                                begin
                                    destino := Dropbox.ListFolder(Copystr(root, 2), Accion::Mover, tipo, false);
                                    if destino = '-' then
                                        error('no ha elegido destino');
                                    if not Continuar then
                                        exit(MoveFolder(CopyStr(root, 2) + '/' + Files.Name, Destino));
                                    MoveFolder(CopyStr(root, 2) + '/' + Files.Name, destino + '/' + Files.Name);
                                    Accion := Accion::" ";
                                    Clear(Dropbox);
                                    exit(ListFolder(Destino, Accion, tipo, Continuar));
                                end;
                        end;
                        If Files.Name = 'Anterior' then begin
                            Files.Name := '';
                            root := Files.Name;
                            If StrPos(Carpeta, '/') > 0 then begin
                                repeat
                                    Barra += 1;

                                    UltimaBarra := CopyStr(Carpeta, barra);

                                until StrPos(UltimaBarra, '/') = 0;
                                Files.Name := CopyStr(Carpeta, 1, barra - 2);
                            end;
                            root := Files.Name;
                            exit(ListFolder(Files.Name, Accion, tipo, Continuar));

                        end else
                            if root = '/' then
                                root += Files.Name
                            else
                                root += '/' + Files.Name;

                        exit(ListFolder(Carpeta + '/' + Files.Name, Accion, tipo, Continuar));
                    end;
                else begin
                    Case Accion Of
                        Accion::Mover:
                            begin
                                destino := Dropbox.ListFolder(Copystr(root, 2), Accion::Mover, tipo, false);
                                if destino = '-' then
                                    error('no ha elegido destino');
                                if not Continuar then
                                    exit(Movefile(Copystr(root, 2), Destino, Files.Name));
                                Movefile(Copystr(root, 2), Destino, Files.Name);
                                Clear(Dropbox);
                                Accion := Accion::" ";
                                root := Destino;
                                exit(ListFolder(Destino, Accion, tipo, Continuar));
                                //exit(MoveFile(Carpeta + '/', CarpetaDestino, Files.Name));
                            end;
                        Accion::Borrar:
                            begin
                                if not continuar then
                                    exit(DeleteFolder(Copystr(root, 2) + '/' + Files.Name, false))
                                else
                                    DeleteFolder(Copystr(root, 2) + '/' + Files.Name, false);
                                exit(ListFolder(Copystr(root, 2), Accion, tipo, Continuar));
                            end;
                        Accion::Seleccionar:
                            exit(Copystr(root, 2) + '/' + Files.Name);
                        Accion::"Descargar Archivo":
                            begin
                                if not continuar then
                                    exit(DowloadFileB64(Copystr(root, 2), Base64Txt, Files.Name, Accion = accion::"Descargar Archivo"))
                                else
                                    DowloadFileB64(Copystr(root, 2), Base64Txt, Files.Name, Accion = accion::"Descargar Archivo");
                                exit(ListFolder(Copystr(root, 2), Accion, tipo, Continuar));
                            end;
                    end;
                end;
            end;

        end;


    end;



    procedure CreateFolder(Carpeta: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //https://api.dropboxapi.com/2/files/create_folder_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + create_folder;
        Body.Add('autorename', false);
        Body.add('path', '/' + Carpeta);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('metadata', JTokO) Then begin
            JsonEntry := JTokO.AsObject();
            If JsonEntry.Get('id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;
        end;
        if strpos(Id, 'id') = 0 then begin
            if StatusInfo.Get('error_summary', JTokO) then begin
                Error(JTokO.AsValue().AsText());
            end;
            Error('Error al crear la carpeta');
        end;
        exit(Id);

        //exit(CreateFolderShared(Carpeta));

    end;
    // {
    // "access_inheritance": "inherit",
    // "acl_update_policy": "editors",
    // "force_async": false,
    // "member_policy": "team",
    // "path": "/example/workspace",
    // "shared_link_policy": "members"
    // }
    procedure CreateFolderShared(Carpeta: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //https://api.dropboxapi.com/2/files/create_folder_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + sharefolder;
        Body.Add('access_inheritance', 'inherit');
        Body.add('acl_update_policy', 'editors');
        Body.add('force_async', false);
        //Body.add('member_policy', 'team');
        Body.add('path', '/' + Carpeta);
        Body.add('shared_link_policy', 'members');
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('shared_folder_id', JnodeEntryToken) Then begin
            If JsonEntry.Get('shared_folder_id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;
        end;
        exit(id);

    end;

    //Move folder
    procedure MoveFolder(Carpeta: Text; NuevaCarpeta: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        // exit('');
        //https://api.dropboxapi.com/2/files/move_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + move_folder;
        Body.add('from_path', '/' + Carpeta);
        Body.add('to_path', '/' + NuevaCarpeta);
        Body.add('allow_shared_folder', true);
        Body.add('autorename', false);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('metadata', JTokO) Then begin
            JsonEntry := JTokO.AsObject();
            If JsonEntry.Get('id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;
        end;
        DeleteFolder(Carpeta, true);
        exit(id);

    end;
    //move_file
    procedure MoveFile(Carpeta: Text; NuevaCarpeta: Text; Archivo: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //https://api.dropboxapi.com/2/files/move_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + move_folder;
        Body.add('from_path', '/' + Carpeta + '/' + Archivo);
        Body.add('to_path', '/' + NuevaCarpeta + '/' + Archivo);
        Body.add('allow_shared_folder', true);
        Body.add('autorename', false);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('metadata', JTokO) Then begin
            JsonEntry := JTokO.AsObject();
            If JsonEntry.Get('id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;
        end;
        exit(id);

    end;

    procedure DeleteFolder(Carpeta: Text; HideDialog: Boolean): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        If Not HideDialog Then
            If Not Confirm('¿Está seguro de que desea eliminar la carpeta?', true) Then
                exit('');
        //https://api.dropboxapi.com/2/files/create_folder_v2
        Ticket := Dropbox.Token();
        if CopyStr(Carpeta, 1, 1) = '/' then
            Carpeta := CopyStr(Carpeta, 2);
        Inf.Get;
        Url := Inf."Url Api DropBox" + delete;
        Body.add('path', '/' + Carpeta);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('metadata', JTokO) Then begin
            JsonEntry := JTokO.AsObject();
            If JsonEntry.Get('id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;
        end;
        exit(id);

    end;

    procedure ListFolderMember(Carpeta: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //https://api.dropboxapi.com/2/files/create_folder_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + list_folfer_members;
        // {
        // "actions": [],
        // "limit": 10,
        // "shared_folder_id": "84528192421"
        // }
        Body.add('limit', 10);
        Body.add('shared_folder_id', Carpeta);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('metadata', JTokO) Then begin
            JsonEntry := JTokO.AsObject();
            If JsonEntry.Get('id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;
        end;
        exit(id);

    end;

    // {
    //     "include_deleted": false,
    //     "include_has_explicit_shared_members": false,
    //     "include_media_info": false,
    //     "path": "/Homework/math"
    // }
    procedure gemetadata(Carpeta: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //https://api.dropboxapi.com/2/files/create_folder_v2
        Ticket := Dropbox.Token();
        Inf.Get;
        Url := Inf."Url Api DropBox" + get_metadata;
        // {
        // "include_deleted": false,
        // "include_has_explicit_shared_members": false,
        // "include_media_info": false,
        // "path": "/Homework/math"
        // }
        Body.add('include_deleted', false);
        Body.add('include_has_explicit_shared_members', false);
        Body.add('include_media_info', false);
        Body.add('path', '/' + Carpeta);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        // {
        //     ".tag": "folder",
        //     "id": "id:a4ayc_80_OEAAAAAAAAAXz",
        //     "name": "math",
        //     "path_display": "/Homework/math",
        //     "path_lower": "/homework/math",
        //     "property_groups": [
        //         {
        //             "fields": [
        //                 {
        //                     "name": "Security Policy",
        //                     "value": "Confidential"
        //                 }
        //             ],
        //             "template_id": "ptid:1a5n2i6d3OYEAAAAAAAAAYa"
        //         }
        //     ],
        //     "sharing_info": {
        //         "no_access": false,
        //         "parent_shared_folder_id": "84528192421",
        //         "read_only": false,
        //         "traverse_only": false
        //         }
        // }
        //recuperar shared_folder_id
        If StatusInfo.Get('sharing_info', JTokO) Then begin
            JsonEntry := JTokO.AsObject();
            // If JsonEntry.Get('parent_shared_folder_id', JnodeEntryToken) Then begin
            //     Id := JnodeEntryToken.AsValue().AsText();
            // end;
            If JsonEntry.Get('shared_folder_id', JnodeEntryToken) Then begin
                Id := JnodeEntryToken.AsValue().AsText();
            end;

        end;
        exit(id);

    end;

    procedure ObtenerToken(CodeDropbox: Text): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        //
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //-default-/public/authentication/versions/1/tickets
        // This code gets the ticket from Dropbox

        Inf.Get;
        Url := Inf."Url Api DropBox" + oauth2_token + '?code=' + CodeDropbox + '&grant_type=authorization_code';
        Respuesta := RestApi(Url, RequestType::post, Json, Inf."Api Key", Inf."Api Secret");
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        // {
        //     "access_token": "sl.u.AbX9y6Fe3AuH5o66-gmJpR032jwAwQPIVVzWXZNkdzcYT02akC2de219dZi6gxYPVnYPrpvISRSf9lxKWJzYLjtMPH-d9fo_0gXex7X37VIvpty4-G8f4-WX45AcEPfRnJJDwzv-",
        //     "expires_in": 14400,
        //     "token_type": "bearer",
        //     "scope": "account_info.read files.content.read files.content.write files.metadata.read",
        //     "refresh_token": "nBiM85CZALsAAAAAAAAAAQXHBoNpNutK4ngsXHsqW4iGz9tisb3JyjGqikMJIYbd",
        //     "account_id": "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc",
        //     "uid": "12345"
        // }
        //recuperar AccessToken y refresh_token

        If StatusInfo.Get('refresh_token', JnodeEntryToken) Then begin
            Id := JnodeEntryToken.AsValue().AsText();
            Inf."Refresh Token" := Id;
            //Añadir 4 horas a la fecha actual
            inf."Fecha Expiracion Token Dropbox" := CurrentDateTime + 14400000;
            Inf.MODIFY;
        end;

        If StatusInfo.Get('access_token', JnodeEntryToken) Then begin
            Id := JnodeEntryToken.AsValue().AsText();
            inf.SetTokenDropbox(Id);
            inf.Modify();
        end;
        exit(id);
    end;

    procedure RefreshToken(): Text
    var
        Dropbox: Codeunit Dropbox;
        Ticket: Text;
        RequestType: Option Get,patch,put,post,delete;
        Inf: Record "Company Information";
        Url: Text;
        Json: Text;
        Body: JsonObject;
        StatusInfo: JsonObject;
        Respuesta: Text;
        JTokO: JsonToken;
        JTok: JsonToken;
        Id: Text;
    begin
        //-default-/public/authentication/versions/1/tickets
        // This code gets the ticket from Dropbox
        Inf.ChangeCompany('Malla Publicidad');
        Inf.Get;
        Url := Inf."Url Api DropBox" + oauth2_token + '?refresh_token=' + Inf."Refresh Token" + '&grant_type=refresh_token';
        Respuesta := RestApi(Url, RequestType::post, '', Inf."Api Key", Inf."Api Secret");
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        // {
        //     "access_token": "sl.u.AbX9y6Fe3AuH5o66-gmJpR032jwAwQPIVVzWXZNkdzcYT02akC2de219dZi6gxYPVnYPrpvISRSf9lxKWJzYLjtMPH-d9fo_0gXex7X37VIvpty4-G8f4-WX45AcEPfRnJJDwzv-",
        //     "expires_in": 14400,
        //     "token_type": "bearer",
        //     "scope": "account_info.read files.content.read files.content.write files.metadata.read",
        //     "refresh_token": "nBiM85CZALsAAAAAAAAAAQXHBoNpNutK4ngsXHsqW4iGz9tisb3JyjGqikMJIYbd",
        //     "account_id": "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc",
        //     "uid": "12345"
        // }
        //recuperar AccessToken y refresh_token

        If StatusInfo.Get('access_token', JnodeEntryToken) Then begin
            Id := JnodeEntryToken.AsValue().AsText();
            Inf.SetTokenDropbox(Id);
            inf."Fecha Expiracion Token Dropbox" := CurrentDateTime + 14400000;
            Inf.MODIFY;
        end;
        exit(id);
    end;

    local procedure ConvertBase64StringToBinaryValue(Value: Text) ReturnValue: Text;
    var
        BinaryValue: Text;
        i: Integer;
        IntValue: Integer;
        PaddingCount: Integer;
    begin
        ReturnValue := Value;
        exit(Value);
        for i := 1 to StrLen(Value) do begin
            if Value[i] = '=' then
                PaddingCount += 1;

            IntValue := GetBase64Number(Value[i]);
            BinaryValue += IncreaseStringLength(IntToBinary(IntValue), 6);
        end;

        for i := 1 to PaddingCount do
            BinaryValue := CopyStr(BinaryValue, 1, StrLen(BinaryValue) - 8);

        ReturnValue := BinaryValue;
    end;

    local procedure IntToBinary(Value: integer) ReturnValue: text;
    begin
        while Value >= 1 do begin
            ReturnValue := Format(Value MOD 2) + ReturnValue;
            Value := Value DIV 2;
        end;
    end;

    local procedure IncreaseStringLength(Value: Text; ToLength: Integer) ReturnValue: Text;
    var
        ExtraLength: Integer;
        ExtraText: Text;
    begin
        ExtraLength := ToLength - StrLen(Value);

        if ExtraLength < 0 then
            exit;

        ExtraText := PadStr(ExtraText, ExtraLength, '0');
        ReturnValue := ExtraText + Value;
    end;


    local procedure GetBase64Number(Value: text): Integer;
    var
        chars: text;
    begin
        if Value = '=' then
            exit(0);

        chars := Base64Chars;
        exit(StrPos(chars, Value) - 1);
    end;

    local procedure Base64Chars(): text;
    begin
        exit('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/');
    end;

    procedure UploadFile(Carpeta: Text; Var DocumentAttach: Record "Document Attachment"): Text
    var
        Inf: Record "Company Information";
        RequestType: Option Get,patch,put,post,;
        Parametros: Text;
        User: Record "User Setup";
        Employe: Record Employee;
        UrlDropbox: Text;
        Ticket: Text;
        Dropbox: Codeunit Dropbox;
        Url: Text;
        Body: JsonObject;
        comit_info: JsonObject;
        Json: Text;

        StatusInfo: JsonObject;
        JTokenLink: JsonToken;
        Respuesta: Text;
        Id: Text;
        DocumentStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Int: Instream;
        Base64Data: Text;
        Bs64: Codeunit "Base64 Convert";
    begin


        TempBlob.CreateOutStream(DocumentStream);
        DocumentAttach."Document Reference ID".ExportStream(DocumentStream);
        TempBlob.CreateInStream(Int);
        //Base64Data := Bs64.ToBase64(Int);
        exit(UploadFileB64(Carpeta, Int, DocumentAttach."File Name"));


    end;


    procedure DowloadFileB64(Carpeta: Text; var Base64Data: Text; Filename: Text; BajarFichero: Boolean): Text
    var
        Inf: Record "Company Information";
        RequestType: Option Get,patch,put,post,;
        Parametros: Text;
        User: Record "User Setup";
        Employe: Record Employee;
        UrlDropbox: Text;
        Ticket: Text;
        Dropbox: Codeunit Dropbox;
        Url: Text;
        Body: JsonObject;
        comit_info: JsonObject;
        Json: Text;

        StatusInfo: JsonObject;
        JTokenLink: JsonToken;
        Respuesta: Text;
        Id: Text;
        DocumentStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Int: Instream;
        Bs64: Codeunit "Base64 Convert";
        GeneralLedgerSetup: Record "General Ledger Setup";
        OutStr: OutStream;
    begin

        Inf.Get;
        Ticket := Dropbox.Token();
        Url := Inf."Url Api DropBox" + get_temporary_link;
        // {
        //     "path": "/Matrices.png",
        //}
        if Carpeta <> '' then
            Body.Add('path', '/' + Carpeta + '/' + FileName)
        else
            Body.Add('path', '/' + FileName);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('link', JTokenLink) Then begin
            Id := JTokenLink.AsValue().AsText();
        end;
        // Clear(Body);
        // GeneralLedgerSetup.Get();
        // Body.add('url', Id);
        // Body.WriteTo(Json);
        TempBlob.CreateInStream(Int);
        //Json := RestApiOfset(GeneralLedgerSetup."Url Alfresco" + 'fetch', RequestType::Post, Json);
        RestApiGetContentStream(Id, RequestType::Get, Int);
        Base64Data := Bs64.ToBase64(Int);
        //Base64Data := Copystr(Json, 2, Strlen(json) - 2);
        If BajarFichero
        then begin
            // TempBlob.CreateOutStream(OutStr);
            // Bs64.FromBase64(Base64Data, OutStr);
            // TempBlob.CreateInStream(Int);
            DownloadFromStream(Int, 'Guardar', 'C:\Temp', 'ALL Files (*.*)|*.*', Filename);


        end;
        exit(Base64Data);

    end;


    procedure UploadFileB64(Carpeta: Text; Base64Data: InStream; Filename: Text): Text
    var
        Inf: Record "Company Information";
        RequestType: Option Get,patch,put,post,;
        Parametros: Text;
        User: Record "User Setup";
        Employe: Record Employee;
        UrlDropbox: Text;
        Ticket: Text;
        Dropbox: Codeunit Dropbox;
        Url: Text;
        Body: JsonObject;
        comit_info: JsonObject;
        Json: Text;

        StatusInfo: JsonObject;
        JTokenLink: JsonToken;
        Respuesta: Text;
        Id: Text;
        DocumentStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Int: Instream;
        Bs64: Codeunit "Base64 Convert";
    begin

        Inf.Get;
        Ticket := Dropbox.Token();
        Url := Inf."Url Api DropBox" + Upload;
        // {
        //     "commit_info": {
        //     "autorename": true,
        //     "mode": "add",
        //     "mute": false,
        //     "path": "/Matrices.png",
        //     "strict_conflict": false
        // },
        //"duration": 14400
        //}
        comit_info.Add('autorename', true);
        comit_info.Add('mode', 'add');
        comit_info.Add('mute', false);
        comit_info.Add('path', '/' + Carpeta + '/' + FileName);
        comit_info.Add('strict_conflict', false);
        Body.Add('commit_info', comit_info);
        Body.Add('duration', 14400);
        Body.WriteTo(Json);
        Respuesta := RestApiToken(Url, Ticket, RequestType::post, Json);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        //{
        // "metadata": {
        //     "name": "math",
        //     "path_lower": "/homework/math",
        //     "path_display": "/Homework/math",
        //     "id": "id:W1FIDMoXTbgAAAAAAAAACQ"
        // }
        //}
        //recuperar id
        If StatusInfo.Get('link', JTokenLink) Then begin
            Id := JTokenLink.AsValue().AsText();
        end;
        Clear(Body);
        //Dococument Attach to base64
        //Base64Data := ConvertBase64StringToBinaryValue(Base64Data);
        Respuesta := RestApiOfset(Id, RequestType::post, Base64Data);
        Clear(StatusInfo);
        StatusInfo.ReadFrom(Respuesta);
        StatusInfo.WriteTo(Json);
        // {
        //     "content-hash": "36f8c3b7be683715edd33ef11d1aeb75aa9b28639fe01f749bc4bb1f5d37b7e0"
        // }
        If StatusInfo.Get('content-hash', JTokenLink) Then begin
            Id := JTokenLink.AsValue().AsText();
        end else
            error(Respuesta);
        exit(id);

    end;


    /// <summary>
    /// GetJArray.
    /// </summary>
    /// <returns>Return variable JArrayPDF of type JsonArray.</returns>
    procedure GetJArray() JArrayPDF: JsonArray;
    begin
        JArrayPDF := JArrayPDFToMerge;
    end;

    procedure Saludo(): Text
    begin
        if time < 140000T then
            exit('Buenos días, ')
        else if time < 200000T then
            exit('Buenas tardes, ')
        else
            exit('Buenas noches, ');
    end;


    /// <summary>
    /// RestApi.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>

    procedure RestApi(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text; User: Text; Pass: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
        Client: HttpClient;
        //RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        MEDIA_TYPE: Label 'application/json';
    begin
        //RequestHeaders := Client.DefaultRequestHeaders();
        CreateBasicAuthHeader(User, Pass, Client);
        //RequestHeaders.Add('Authorization', 'Basic YzQ1MHNtODI1N3pjaTR2Om9lOG1qMnA2YTJjODA0bA==');
        //RequestHeaders.Add('Cookie', 'ARRAffinity=ac224ea6cd3e4374e03fbe50c5a3cebec4b91d61a2fedb4b8a49f8025294b435;ARRAffinitySameSite=ac224ea6cd3e4374e03fbe50c5a3cebec4b91d61a2fedb4b8a49f8025294b435');
        // CreateBasicAuthHeader(User, Pass, Client);
        //Client.Timeout := 0;

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    If payload <> '' then
                        RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    procedure CreateBasicAuthHeader(UserName: Text[50]; Password: Text[50]; var HttpClient: HttpClient);
    var
        AuthString: Text;
        TypeHelper: Codeunit "Base64 Convert";
    begin
        AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        AuthString := TypeHelper.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
        HttpClient.DefaultRequestHeaders().Add('Authorization', AuthString);
    end;

    procedure RestApiOfset(url: Text; RequestType: Option Get,patch,put,post,delete; payload: instream): Text
    var
        Ok: Boolean;
        Respuesta: Text;
        Client: HttpClient;
        //RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
    //MEDIA_TYPE: Label 'application/json';
    begin
        //url := GlSetup."Url" + url;

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/octet-stream');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    //RequestMessage.Content.WriteFrom(payload);
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/octet-stream');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::put:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Put(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    procedure RestApiGetContentStream(url: Text; RequestType: Option Get,patch,put,post,delete; var payload: InStream)
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: InStream;
        contentHeaders: HttpHeaders;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        //RequestHeaders.Add('Authorization', CreateBasicAuthHeader(Username, Password));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                begin


                    Client.Delete(URL, ResponseMessage);
                end;
        end;

        ResponseMessage.Content().ReadAs(payload);
        //exit(ResponseText);

    end;


    /// <summary>
    /// RestApiToken.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="Token">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure RestApiToken(url: Text; Token: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        MEDIA_TYPE: Label 'application/json';

    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', token));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::put:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Put(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;



}