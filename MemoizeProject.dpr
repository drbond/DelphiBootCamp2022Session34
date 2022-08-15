Program MemoizeProject;
 {Based on an article by Pavlov Prilukov - }
 {https://habr-com.translate.goog/en/post/244945/?_x_tr_sl=auto&_x_tr_tl=en&_x_tr_hl=en}
{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils,
  DateUtils,
  System.Generics.Collections;

Type
  TReferenceToFunctionOfx = Reference To Function(x : Integer): Double;
  TMemoize = Reference To Function(f : TReferenceToFunctionOfx): TReferenceToFunctionOfx;
Var
  Memoize : TMemoize;
  Calc : TReferenceToFunctionOfx;
  MemoizedCalc : TReferenceToFunctionOfx;
  i : Integer;
  Time : TDateTime;
  MillisecondsForNonMemoizedResult, MillisecondsForMemoizedResult : Int64;
  MillisecondsForMemoization : Int64;
  NonMemoizedResult, MemoizedResult : Double;

Begin
  //Method reference to method f(x) + cache which grows with each call to f(x)
  Memoize := Function(f : TReferenceToFunctionOfx ) : TReferenceToFunctionOfx
               Var
                 Cache : TDictionary<Integer, Double>; //This local variable
                                                       //will be captured in closure
               Begin
                 Cache := TDictionary<Integer, Double>.Create;
                 Result := Function(x : Integer): Double
                             Begin
                               If Not Cache.ContainsKey(x) //If no stored values in the cache
                                 Then
                                   Begin
                                     Result := f(x); //Have to evaluate the function f(x)
                                     Cache.Add(x, Result); //and remember the result
                                   End
                               Else Result := Cache[x];
                             End;
               End;

  Calc := Function(x : Integer) : Double
            Var
              i : Integer;
            Begin
              Result := 0;
              For i := 1 to High(Word)      //0..65535
                Do Result := Result + (Ln(i) / Sin(i)) * x;
            End;

  MemoizedCalc := Memoize(Calc); //Returns a method ref to an anonymous function (the inner anon. function)
                                 //of argument x. The inner anonymous function captures
                                 //parameter f which is bound to Calc in this call Memoize(Calc).
                                 //The cache is also captured and bound to the
                                 //inner anonymous function so this function may
                                 //populate the cache with result
                                 //from each call of Calc(x) for which cache
                                 //doesn't have a matching entry for value of x
                                 //MemoizedCalc needs a value for x

  NonMemoizedResult := 0;

  Time := Now;
  For i := 1 To 100
    Do NonMemoizedResult := NonMemoizedResult + Calc(i Mod 100);
  MillisecondsForNonMemoizedResult := MilliSecondsBetween(Now, Time);
  Writeln('Loop from 1 to ', i - 1, ' takes without memoization = ',
           MillisecondsForNonMemoizedResult, ' ms');
  //For i := 1 To 100 Do Writeln(i Mod 100);
  MemoizedResult := 0;
  Time := Now;
  For i := 1 To 100
    Do MemoizedResult := MemoizedResult + MemoizedCalc(i Mod 100); //1..99, 0 repeated 10 times
  MillisecondsForMemoizedResult := MilliSecondsBetween(Now, Time);
  Writeln('Loop from 1 to ', i - 1, ' takes using memoized result = ',
           MillisecondsForMemoizedResult, ' ms');
  Writeln('Press return key to quit');
  Readln;
End.
