//Crear expresión de tabla para la tabla CompanyInfo para agregar campos adicionales a la tabla.
tableextension 90600 "CompanyInfoExt" extends "Company Information"
{
    fields
    {
        field(90600; "Token Dropbox"; Blob)
        {
            //sl.u.AFNERKJ4EZ5LzJlm5qHi0SrLJj-o-4eTWjlYkm-L-kQXA51-93qYyCaU1Ay4Hy72PdnOEzLCjdMVd2eE1maLUtJo0ogXQiyPDOrTgtrZM_g99Ciwc0s6u1DA1FtXJbNRlPdj3Pph2NyA484_AL_CF04Os7wwoH6E5Hck7gGxVDEM_GgFigqTh6svpxw2K_mmhgwRJwTyNam9Apt9RmQxzb8-MeZAIhK5RVixXu2pSl3a_UORmXh-NbpZczI7JdzPgF_UcMDqy_IGrwAU43U4ku5cb_5qDzrzfgL_RN_mo8DL-X2_XJFdKDkWWzEc0hTsX4vjBzRPk_E3Gi2oVdNHWwfQWyG3gwhl2jIjNIeLm3YAiF9M7J3pHzk1QaG21TrcR5st83xdokM4FkNTf0YDlV_eWF5Ft7LuekJ51TA7xW0daRlMuYtA-ytPJBsnqON-fJJgbgEs6beHE7Itd1ib2uZJopu5k9H-pn0-FDnRom8A88rpGxPaDsQeFQjR9gf-fhCHS458DCHomF6RkTuw7BBx-OjBRVtIE4XVhQuod51VO8-sahVHgwxMTZB0acJxCS85fx4LHVVlszGctqXsU0MEJYaQt6GqQejWg8i9SiaETPSOQ_i5GG6-kITgWVpDheItkfNyeEdiJEBqDEeitfVVQPFyMUjdCmOfCjmIj23QwqgjnqDuANguewyhtAmKmtvqPzGlkmgA_QONfGgnVYLY8WV-qp9yBm-wf0ZzS3ow0KGA_EWdWCozqcM_IdgP7t9WT72g9K8la4D5O38pCaGJ0Vfy5B4AAuXLLBqkJv7iyAfmoHSojmP_v-qEbbYS17VNAHurPMRWwwbtk02GOC6MJZLLC7CGYpDXxaLOz0uukdPPAnj2kbf_c2QzD_XBGbEqDJlrOjIvgAgN0r4SZxeQcSBTy4j6cfcAMu4x5qs0uR2x8CGSjb4FsHiL-_iWnjcqkPPbAR5XKGgJWybW1G7NGTGyT1adL8TAdZKlTWNXQ_MzuGJckYnZnMrvzWl3RWKJYkDe5axdXu8sBNG93ZIAFlbQNQ185PzFRih-7labRf7Y9D06gdI5aB5Ep6hCT8zP-FIzjLYIizc0vh54YMDquDwHedMvaUQUU2NNP8WeMS2a_H9KRj2Cgz4TtCSdFdkiIHpSMywC94tTRI5Aq3mayB2LMRWPcHujfwk3iblxbS4ebiwzn5em1zywDMQcRpdn6pRxfkuozmgXMOagjY8ht9Mb4ZCr1yLQ_OswT63_I-I5B5bHIVuPLypTrv2vuZJlZofYTQPa8rkY0sb54E2d
            DataClassification = ToBeClassified;
        }
        field(90601; "Url Api DropBox"; Text[250])
        {
            DataClassification = ToBeClassified;
            //https://api.dropboxapi.com/2/
        }
        field(90602; "Api Secret"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(90603; "Api Key"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(90604; "Refresh Token"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(90605; "Fecha Expiracion Token Dropbox"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
    }
    procedure SetTokenDropbox(NewTokenDropbox: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Token Dropbox");
        "Token Dropbox".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewTokenDropbox);
        Modify();
    end;

    procedure GetTokenDropbox() TokenDropbox: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Token Dropbox");
        "Token Dropbox".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName("Token Dropbox")));
    end;
}