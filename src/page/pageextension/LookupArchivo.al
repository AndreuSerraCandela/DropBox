pageextension 96001 LokupFile extends "Name/Value Lookup"
{
    layout
    {
        modify(Name)
        {
            StyleExpr = Carpetas;
            trigger OnAssistEdit()
            begin
                if Rec.Name = '..' then begin
                    Nombre := 'Anterior';
                    Rec.Value := 'Carpeta';
                    Accion := Accion::Anterior;
                    if not Mueve then
                        Accion := Accion::Anterior;
                    CurrPage.Close();
                end;
                Nombre := Rec.Name;
                if Rec.Value = 'Carpeta' then
                    Accion := Accion::" "
                else
                    Accion := Accion::"Descargar Archivo";
                if Acciones then
                    CurrPage.Close();
            end;
        }
    }
    actions
    {
        addfirst(Processing)
        {
            action("Seleccionar")
            {
                ApplicationArea = All;
                Visible = (Not Mueve);
                Image = SelectChart;
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
                    Accion := Accion::"Seleccionar";
                    CurrPage.Close();
                end;
            }
            action("Anterior")
            {
                ApplicationArea = All;
                Visible = true;
                Image = PreviousRecord;
                trigger OnAction()
                begin
                    Nombre := 'Anterior';
                    Rec.Value := 'Carpeta';
                    Accion := Accion::Anterior;
                    if not Mueve then
                        Accion := Accion::Anterior;
                    CurrPage.Close();
                end;
            }
            action("Descargar Archivo")
            {
                ApplicationArea = All;
                Visible = (Archivo and Not Mueve);
                Image = Download;
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
                    Accion := Accion::"Descargar Archivo";
                    CurrPage.Close();
                end;
            }
            action(Mover)
            {
                ApplicationArea = All;
                Visible = Not Mueve;
                Image = Change;
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
                    Accion := Accion::Mover;
                    CurrPage.Close();
                end;
            }
            // action("Seleccionar Destino")
            // {
            //     ApplicationArea = All;
            //     Visible = Mueve;
            //     Image = Select;
            //     trigger OnAction()
            //     begin
            //         Nombre := Rec.Name;
            //         Accion := Accion::"Seleccionar Destino";
            //         Mueve := False;
            //         //Rec.Value := 'Seleccionada';
            //         CurrPage.Close();
            //     end;
            // }
            action("Crear Carpeta")
            {
                ApplicationArea = All;
                Image = ToggleBreakpoint;
                Visible = not Mueve;
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
                    Nombre := Carpeta;
                    Accion := Accion::"Crear Carpeta";
                    CurrPage.Close();
                end;
            }
            action(Borrar)
            {
                ApplicationArea = All;
                Image = Delete;
                Visible = not Mueve;
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
                    Accion := Accion::Borrar;
                    CurrPage.Close();
                end;
            }
            action("Subir Archivo")
            {
                ApplicationArea = All;
                Image = Import;
                Visible = (not Mueve);
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
                    Accion := Accion::"Subir Archivo";
                    Rec.Value := 'Carpeta';
                    CurrPage.Close();
                end;
            }
        }
        addfirst(Promoted)
        {
            actionref(Seleccionar_Ref; "Seleccionar") { }
            actionref(Anterior_Ref; Anterior) { }
            actionref(Mover_Ref; "Mover") { }
            actionref(DescargarArchivo_Ref; "Descargar Archivo") { }
            actionref(CrearCarpeta_Ref; "Crear Carpeta") { }
            actionref(Borrar_Ref; Borrar) { }
            actionref(SubirArchivo_Ref; "Subir Archivo") { }

            // actionref(SeleccionarDestino_Ref; "Seleccionar Destino") { }
        }
    }
    procedure Navegar(root: Text)
    begin
        Caption := root;
        Acciones := True;
        Nombre := '-';
    end;

    var
        Acciones: Boolean;
        Nombre: Text;
        Carpeta: Boolean;
        Archivo: Boolean;
        Mueve: Boolean;
        Accion: Option " ","Seleccionar","Anterior","Descargar Archivo","Mover","Crear Carpeta",Borrar,"Subir Archivo";
        Carpetas: Text;

    Procedure GetNombre(Var Nom: Text; Var Valor: Text; Var pAccion: Option "  ","Seleccionar","Anterior","Descargar Archivo","Mover","Crear Carpeta",Borrar,"Subir Archivo")
    begin
        Nom := Nombre;
        If Accion in [Accion::Anterior, Accion::"Crear Carpeta"] then
            Valor := 'Carpeta'
        else
            Valor := Rec.Value;
        // if Mueve then
        //   pAccion := Accion::Mover;
        pAccion := Accion;
    end;

    trigger OnAfterGetRecord()
    begin
        If Acciones then begin
            if Rec.Value = 'Carpeta' then begin
                Carpeta := True;
                Archivo := False;
            end
            else begin
                Carpeta := False;

                Archivo := True;
            end;
        end;
        if Carpeta then
            Carpetas := 'StrongAccent'
        else
            Carpetas := '';
    end;

    procedure Mover()
    begin
        Mueve := True;
        Rec.SetRange(Value, 'Carpeta');
    end;
}