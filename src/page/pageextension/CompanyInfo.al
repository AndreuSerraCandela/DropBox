//Crear extension page CopmanyInfo para agregar campos adicionales a la tabla.
pageextension 96000 "CompanyInfoExt" extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group("DropBox")
            {
                field("Token DorpBox"; TokenDropbox)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the products or service being offered';

                    trigger OnValidate()
                    begin
                        Rec.SetTokenDropbox(TokenDropbox);
                    end;
                }
                field("Url Api DropBox"; Rec."Url Api DropBox")
                {
                    ApplicationArea = All;
                }
                field("Api Secret"; Rec."Api Secret")
                {
                    ApplicationArea = All;
                }
                field("Api Key"; Rec."Api Key")
                {
                    ApplicationArea = All;
                }
            }

        }
    }
    actions
    {
        addfirst(Processing)
        {
            group("Acciones DropBox")
            {
                Caption = 'DropBox';
                action("Get Token DropBox")
                {
                    ApplicationArea = All;
                    Image = ToggleBreakpoint;
                    Caption = 'Optener Código DropBox';
                    ToolTip = 'Crea permisos para la aplicación en DropBox';
                    trigger OnAction()
                    var
                        DorpBox: Codeunit "DropBox";
                        Ventana: Page "Dialogo Dropbox";
                        CodeDropBox: Text;
                    begin
                        Hyperlink('https://www.dropbox.com/oauth2/authorize?client_id=' + Rec."Api Key" + '&response_type=code&token_access_type=offline');
                        Ventana.SetTexto('Código DropBox');
                        Ventana.RunModal();
                        Ventana.GetTexto(CodeDropBox);
                        DorpBox.ObtenerToken(CodeDropBox);
                    end;
                }
                action("Crear Carpeta")
                {
                    ApplicationArea = All;
                    Image = ToggleBreakpoint;
                    Caption = 'Crear Carpeta';
                    ToolTip = 'Crea una carpeta en DropBox';
                    trigger OnAction()
                    var
                        DorpBox: Codeunit "DropBox";
                        Ventana: Page "Dialogo Dropbox";
                        Carpeta: Text;
                    begin
                        Ventana.SetTexto('Nombre Carpeta');
                        Ventana.RunModal();
                        Ventana.GetTexto(Carpeta);
                        DorpBox.CreateFolder(Carpeta);
                    end;
                }
                action("Borrar Carpeta")
                {
                    ApplicationArea = All;
                    Image = ToggleBreakpoint;
                    Caption = 'Borrar Carpeta';
                    trigger OnAction()
                    var
                        DorpBox: Codeunit "DropBox";
                        Ventana: Page "Dialogo Dropbox";
                        Carpeta: Text;
                    begin
                        Ventana.SetTexto('Nombre Carpeta');
                        Ventana.RunModal();
                        Ventana.GetTexto(Carpeta);
                        DorpBox.DeleteFolder(Carpeta);
                    end;
                }
                action("Listar Carpeta")
                {
                    ApplicationArea = All;
                    Image = ToggleBreakpoint;
                    Caption = 'Listar Carpeta';
                    ToolTip = 'Listar una carpeta de DropBox';
                    trigger OnAction()
                    var
                        DorpBox: Codeunit "DropBox";
                        Ventana: Page "Dialogo Dropbox";
                        Carpeta: Text;
                    begin
                        Ventana.SetTexto('Nombre Carpeta');
                        Ventana.RunModal();
                        Ventana.GetTexto(Carpeta);
                        DorpBox.ListFolder(Carpeta, true);
                    end;
                }
                action("Subir Arcivo")
                {
                    ApplicationArea = All;
                    Image = Save;
                    Caption = 'Subir Archivo';
                    ToolTip = 'Subir archivo a una carpeta en DropBox';
                    trigger OnAction()
                    var
                        DorpBox: Codeunit "DropBox";
                        Ventana: Page "Dialogo Dropbox";
                        Carpeta: Text;
                        Base64Txt: Text;
                        NVInStream: InStream;
                        Base64: Codeunit "Base64 convert";
                        Filename: Text;
                    begin
                        Ventana.SetTexto('Nombre Carpeta Destino');
                        Ventana.RunModal();
                        Ventana.GetTexto(Carpeta);
                        UPLOADINTOSTREAM('Import', '', ' All Files (*.*)|*.*', Filename, NVInStream);
                        //Base64Txt := Base64.ToBase64(NVInStream);
                        DorpBox.UploadFileB64(Carpeta, NVInStream, Filename);
                    end;
                }
                action("Miembros Carpeta")
                {
                    ApplicationArea = All;
                    Image = ToggleBreakpoint;
                    Caption = 'Miembros Carpeta';
                    trigger OnAction()
                    var
                        DorpBox: Codeunit "DropBox";
                        Ventana: Page "Dialogo Dropbox";
                        Carpeta: Text;
                    begin
                        Ventana.SetTexto('Nombre Carpeta');
                        Ventana.RunModal();
                        Ventana.GetTexto(Carpeta);
                        Carpeta := DorpBox.gemetadata(Carpeta);
                        Carpeta := DorpBox.ListFolderMember(Carpeta);
                    end;
                }
            }
        }
        addlast(Promoted)
        {
            group("&Dropbox")
            {
                actionref("Get Token DropBox_Promoted"; "Get Token DropBox")
                {

                }

            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        TokenDropbox := Rec.GetTokenDropbox();

    end;

    var
        TokenDropbox: Text;
}