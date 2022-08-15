Program ParallelVersusNonParallelPrimes;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Diagnostics,
  System.Threading,
  System.SyncObjs,
  System.Classes;

Function IsPrime(n : Int64) : Boolean;
  Begin
    Var k : Int64 := Trunc(Sqrt(n));
    Var i : Int64 := 2;
    While  (i <= k) And ((n Mod i) <> 0)
      Do Inc(i);
    Result := i > k;
  End;

Const
  UpperInteger = 10000000;//ten million

Var
  Total : Integer;
  StopWatch : TStopWatch;
Begin
  Try
     // counts the prime numbers below a given value using a single thread
     Total := 0;
     StopWatch :=TStopWatch.Create;
     StopWatch.Start;
     For Var i : Int64 := 2 To UpperInteger
       Do
         If IsPrime(i)
           Then Total := Total + 1;
     StopWatch.Stop;
     Writeln(Format('Non-parallel For loop. Time (in milliseconds): %d - Primes found: %d', [StopWatch.ElapsedMilliseconds,Total]));

     //counts the prime numbers below a given value using parallelisation of the loop
     Total := 0;
     StopWatch :=TStopWatch.Create;
     StopWatch.Start;
     TParallel.For(2, UpperInteger, Procedure(i : Int64)
                                      Begin
                                        If IsPrime(i)
                                          Then TInterlocked.Increment(Total);
                                      End);
     StopWatch.Stop;
     Writeln(Format('Parallel For loop. Time (in milliseconds): %d - Primes found: %d', [StopWatch.ElapsedMilliseconds,Total]));
     Readln;
   Except On E : EAggregateException
     Do Writeln(E.ToString);
   End;
End.
