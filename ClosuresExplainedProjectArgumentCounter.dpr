Program ClosuresExplainedProjectArgumentCounter;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;

Type
  TAnonymousFunctionRef1 = Reference To Function(AnInteger : Integer) : Integer; //TFunc<Integer, Integer>

Var
  IncrementCounterBy : TAnonymousFunctionRef1;

Function Increment(Counter : Integer) : TAnonymousFunctionRef1;
  Begin
    Result := Function(HowMuchToAddToCounter : Integer) : Integer
                Begin
                  Counter := Counter + HowMuchToAddToCounter;
                  Result := Counter;
                End;
    Writeln('Counter = ', Counter);
  End;

Begin
  IncrementCounterBy := Increment(0);
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Readln;
End.
