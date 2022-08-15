Program EmulatingAnonymousMethodsProject;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils;

Type
  TIntFunc = Function(Value : Integer): Integer; // Function pointer type

  // An interface is a class with no implementation,
  // e.g. IDiet = Interface Function GetDiet : String End;

  IIntFuncRef = Reference To Function(Value : Integer): Integer; // Compiler generates an interface with
                                                                 // a single method Invoke with same
                                                                 // signature as function

  // TInterfacedObject is a base for simple classes that need a
  // basic IInterface implementation.
  // TInterfacedObject is a thread-safe base class for Delphi classes that support interfaces.
  // An anonymous method is internally an interface with a single method “Invoke”:
  TAnonCaller = Class(TInterfacedObject, IIntFuncRef) //TInterfacedObject = Class(TObject, IInterface)
                  Private
                    FFunc : TIntFunc; //Function pointer
                    Function Invoke(Value : Integer) : Integer; //Single method named Invoke,
                    //                  behind which calls the anonymous method that you provide.
                  Public
                    Constructor Create(AFunc : TIntFunc);
                End;
Constructor TAnonCaller.Create(AFunc : TIntFunc);
  Begin
    FFunc:= AFunc;
  End;

Function TAnonCaller.Invoke(Value : Integer) : Integer;
  Begin
    Result:= FFunc(Value);
  End;

Function Square(Value : Integer) : Integer;
  Begin
    Result:= Value * Value;
  End;
Var
  AnonMethod : IIntFuncRef;
  x : TObject;
Begin
  ReportMemoryLeaksOnShutdown := True;
  x := TObject.Create; //used to show that the interface object is memory managed
                      //so doesn't need to be explicitly freed whereas x does.

  // when an anonymous method an instance of the class TAnonCaller
  // is instantiated and a reference to this object returned and
  // assigned to AnonMethod.
  // When the anonymous method is called the Invoke method of the interface is called.

  AnonMethod := TAnonCaller.Create(@Square);
  Writeln(IntToStr(AnonMethod(2))); // When AnonMethod called, the function Invoke
                                   // is executed which executes Square(2).
  // When anonymous methods are used instead of the emulation shown above,the compiler
  // creates, behind the scenes, a hidden class that implements the anonymous method interface.
  // That class contains as data members any variables that are captured.
  Readln;
  IsConsole := False;
End.

