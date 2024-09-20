pageextension 96001 LokupFile extends "Name/Value Lookup"
{
    actions
    {
        addfirst(Processing)
        {
            action("Abrir Carpeta")
            {
                ApplicationArea = All;
                Visible = Carpeta;
                Image = NextRecord;
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
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
                    CurrPage.Close();
                end;
            }
            action("Descargar Archivo")
            {
                ApplicationArea = All;
                Visible = Archivo;
                Image = Download;
                trigger OnAction()
                begin
                    Nombre := Rec.Name;
                    CurrPage.Close();
                end;
            }
        }
        addfirst(Promoted)
        {
            actionref(ANterior_Ref; Anterior) { }
            actionref(AbrirCarpeta_Ref; "Abrir Carpeta") { }
            actionref(DescargarArchivo_Ref; "Descargar Archivo") { }
        }
    }
    procedure Navegar()
    begin
        Acciones := True;
    end;

    var
        Acciones: Boolean;
        Nombre: Text;
        Carpeta: Boolean;
        Archivo: Boolean;

    Procedure GetNombre(Var Nom: Text; Var Valor: Text)
    begin
        Nom := Nombre;
        Valor := Rec.Value;
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
    end;
}