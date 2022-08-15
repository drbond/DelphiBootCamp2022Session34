Program IntroductionToReduceProject;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;

Type
  TFunctionOfInteger = Reference to Function(x, y : Integer) : Integer;
  TArrayOfInteger = Array Of Integer;
Var
  AnArrayOfInteger : TArrayOfInteger = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

Function Reduce(f : TFunctionOfInteger; InitialValue : Integer;
                ArrayOfInteger : TArrayOfInteger) : Integer;
  Begin
    Result := InitialValue;  {Result performs role of accumulator}
    For Var i := Low(ArrayOfInteger) To High(ArrayOfInteger)
      Do Result := f(ArrayOfInteger[i], Result);
  End;
Begin
  Var Sum := Reduce(Function(x, y : Integer) : Integer
                                  Begin
                                    Result := x + y;
                                  End, 0, AnArrayOfInteger);
  Writeln('Sum: ', Sum);
  Readln;
End.
