Program IntroductionToFilterProject;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;

Type
  TFunctionOfInteger = Reference to Function(x : Integer) : Boolean;
  TArrayOfInteger = Array Of Integer;
Var
  AnArrayOfInteger : TArrayOfInteger = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  AnotherArrayOfInteger : TArrayOfInteger;

Function Filter(f : TFunctionOfInteger; ArrayOfInteger : TArrayOfInteger) : TArrayOfInteger;
  Var Count, NewLength : Integer;
  Begin
    Count := -1;
    NewLength := 0;
    For Var i := Low(ArrayOfInteger) To High(ArrayOfInteger)
      Do
        If f(ArrayOfInteger[i])
          Then
            Begin
              Inc(Count);
              Inc(NewLength);
              SetLength(Result, NewLength);{Extends the array's length}
              Result[Count] := ArrayOfInteger[i];
            End;
  End;
Begin
  AnotherArrayOfInteger := Filter(Function (Item : Integer) : Boolean
                                    Begin
                                      Result := Item Mod 2 = 0; {Tests for evenness}
                                    End, AnArrayOfInteger);
  For Var i :=  Low(AnotherArrayOfInteger) To High(AnotherArrayOfInteger)
    Do Writeln(AnotherArrayOfInteger[i]);
  Readln;
End.
