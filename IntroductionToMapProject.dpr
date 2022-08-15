Program IntroductionToMapProject;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;
Type
  TFunctionOfInteger = Reference to Function(x : Integer) : Integer;
  TArrayOfInteger = Array Of Integer;
Var
  AnArrayOfInteger : TArrayOfInteger = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  AnotherArrayOfInteger : TArrayOfInteger;
Function Map(f : TFunctionOfInteger; ArrayOfInteger : TArrayOfInteger) : TArrayOfInteger;
  Begin
    SetLength(Result, Length(ArrayOfInteger)); {Result stores reference to array block of memory}
    For Var i := Low(ArrayOfInteger) To High(ArrayOfInteger)
      Do Result[i] := f(ArrayOfInteger[i]);
  End;
Begin
  AnotherArrayOfInteger := Map(Function(x : Integer) : Integer
                                  Begin
                                    Result := x * x;
                                  End, AnArrayOfInteger);
  Writeln('Contents of original array    Contents of returned array');
  For Var i :=  Low(AnotherArrayOfInteger) To High(AnotherArrayOfInteger)
    Do Writeln(AnArrayOfInteger[i] : 10, ' ' : 30, AnotherArrayOfInteger[i]);
  Readln;
End.
