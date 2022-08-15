Program PolynomialSumProject;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils, System.Math;

Type
  TPolynomialFunction = Reference To Function(x : Double) : Double;

Function Sum (n : Integer; f : TPolynomialFunction) : Double;
  Begin
    Result := 0.0;
    For Var i := 1 To n Do Result := Result + f(i);
  End;
Begin

  Writeln('Sum = ', Sum(3, Function(x : Double) : Double
                             Begin
                               Result := x;  // 1 + 2 + 3
                             End) : 16 : 12);
  Writeln('Sum = ', Sum(100, Function(x : Double) : Double
                               Begin
                                 Result := cos(x);
                               End) : 16 : 12); //cos(1) + cos(2) + cos(3) + ...
  Writeln('Sum = ', Sum(10, Function(x : Double) : Double
                              Begin
                                Result := 1/(Power(2, x));
                              End) : 16 : 12); // 1/2 + 1/4 + 1/8 + ...
  Writeln('Sum = ', Sum(15, Function(x : Double) : Double
                              Begin
                                Result := 1/(Power(2, x)); // 1/2 + 1/4 + 1/8 + ...
                              End) : 16 : 12);
  Writeln('Sum = ', Sum(40, Function(x : Double) : Double
                              Begin
                                Result := 1/(Power(2, x)); // 1/2 + 1/4 + 1/8 + ...
                              End) : 16 : 12);
  Writeln('Sum = ', Sum(50, Function(x : Double) : Double
                              Begin
                                Result := 1/(Power(2, x)); // 1/2 + 1/4 + 1/8 + ...
                              End) : 32 : 28);
  Readln;
End.
