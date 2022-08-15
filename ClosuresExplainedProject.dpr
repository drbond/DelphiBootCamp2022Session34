Program ClosuresExplainedProject;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;

Type
  TAnonymousFunctionRef1 = Reference To Function(AnInteger : Integer) : Integer; //TFunc<Integer, Integer>

Var
  IncrementCounterBy : TAnonymousFunctionRef1;

Function Increment : TAnonymousFunctionRef1;
  Var
    Counter : Integer;
  Begin
    Counter := 0;
    Result := Function(HowMuchToAddToCounter : Integer) : Integer
                Begin
                  Counter := Counter + HowMuchToAddToCounter;
                  Result := Counter;
                End;
    Writeln('Counter = ', Counter);
  End;

Begin
  IncrementCounterBy := Increment();
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Writeln(IncrementCounterBy(1));
  Readln;
End.
