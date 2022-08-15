Program UsingRTTIForAdd6Project;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils,
  Rtti, Winapi.Windows,
  ConsoleTextColourUnit in 'ConsoleTextColourUnit.pas';

Type
  TFunctionOfInteger = Reference To Function(Parameter : Integer) : Integer;

Function f(x : Integer) : TFunctionOfInteger; //Ctrl + 3
//Var z : Integer;
  Begin
   // z := 9;
    Result := Function(y : Integer) : Integer //Captures argument x
      Begin
        Result := x + y; // + z;
      End;
  End;

Procedure WriteInterfaceInfo(myTObject : TObject; NameOfSpecialisedFunction : String); //Ctrl + 2
  Begin
    Var myClass : TClass := myTObject.ClassType;
    Var LContext : TRttiContext := TRttiContext.Create;
    Var LType : TRttiType := LContext.GetType(myClass);

    If LType is TRttiInstanceType
      Then
        Begin
          SetC(4); //Remeber that a closure uses the interface mechanism
            Writeln('The specialised function ', NameOfSpecialisedFunction,
                     ' is located in an instance of the type ',
                     myTObject.ClassName); //f$ActRec is the name of the class that that implements interface
          ResetC;
          Writeln('This instance is located at memory address ', Integer(Addr(Pointer(MyTObject)^)));
          Writeln('and the instance has ', Length(LType.GetFields), ' fields');

          Var NoOfFields : Integer := 0;
          For Var LField : TRttiField In LType.GetFields
            Do
              Begin
                NoOfFields := NoOfFields + 1;
                SetC(5);
                  Writeln('Field number ', NoOfFields, ' has field name ', LField.Name,
                          ' and data type ', LField.FieldType.ToString,
                          ', it has the value ',
                  LType.GetField(LField.Name).GetValue(myTObject).ToString,
                  ' and its offset in the instance is ', LField.Offset);
                ResetC;
              End;
          {The reference count is 2 because we have both the specialised add function
           referencing the instance and the IInterface variable via the use of Absolute}
        End;

  End;

Var
  Add6 : TFunctionOfInteger;
  Add8 : TFunctionOfInteger;
  InterfaceRef : IInterface Absolute Add6;//Absolute means variable InterfaceRef
    //should reference the same address as Add6
  {https://docwiki.embarcadero.com/RADStudio/Alexandria/en/Variables_(Delphi)#Absolute_Addresses}
  InterfaceRef1 : IInterface Absolute Add8;
Begin
  ReportMemoryLeaksOnShutdown := True;

  Add6 := f(6); //Specialised function, Ctrl + Space, Ctrl + 4

  Var myTObject : TObject := (InterfaceRef As TObject); //InterfaceRef references closure object
  Var myClass : TClass := myTObject.ClassType;

  Var LContext : TRttiContext := TRttiContext.Create;
  Var LType : TRttiType := LContext.GetType(myClass);
  SetC(2);   //Setting colour of text written to console
    Writeln('In this exercise, a closure is used to produce a specialised single argument add function');
    Writeln('The specialised add function is a pure function: it has no side-effects ');
    Writeln('and for a given argument the value returned is always the same');
  ResetC; //Resetting colour of text written to console
  Writeln('--------------------------------------------------------------------------------------');
  Write('Call specialised function Add6 with argument 8, result returned is ');
  SetC(4); Writeln(Add6(8).ToString); ResetC;

  Writeln('--------------------------------------------------------------------------------------');
  WriteInterfaceInfo(myTObject, 'Add6');  //Ctrl + 1

  Writeln('--------------------------------------------------------------------------------------');

  Add8 := f(8);
  Var myTObject2 := (InterfaceRef1 As TObject);
  Write('Call specialised function Add8 with argument 16, result returned is ');
  SetC(4);  Writeln(Add8(16).ToString); ResetC;

  Writeln('--------------------------------------------------------------------------------------');
  WriteInterfaceInfo(myTObject2, 'Add8');

  Writeln('--------------------------------------------------------------------------------------');
  SetC(3);
    Writeln('Add6 with argument 100 returns ', Add6(100));
    Writeln('Add8 with argument 100 returns ', Add8(100));
  ResetC;
  Readln;
End.
