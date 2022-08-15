Program DelphiAdd2Project;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;
Type
  TFunctionOfInteger = Reference To Function(Parameter : Integer) : Integer;
  Function f(x : Integer) : TFunctionOfInteger;
    Begin
      Result := Function(y : Integer) : Integer
        Begin
          Result := x + y;
        End;
    End;
Begin
  Writeln(f(2)(60));
  Readln;
End.
