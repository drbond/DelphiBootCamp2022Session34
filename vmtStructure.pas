{*****************************************************************************
* The contents of this file are used with permission, subject to
* the Mozilla Public License Version 1.1 (the "License"); you may
* not use this file except in compliance with the License. You may
* obtain a copy of the License at
* http://www.mozilla.org/MPL/MPL-1.1.html
*
* Software distributed under the License is distributed on an
* "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
* implied. See the License for the specific language governing
* rights and limitations under the License.
*
*****************************************************************************
*
* This file was created by Mason Wheeler.  He can be reached for support at
* tech.turbu-rpg.com.
*****************************************************************************}

unit vmtStructure;

{$I jedi.inc} //sets up version defines

interface
uses
  typInfo;

type
   // thanks to Hallvard Vassbotn for this information
   // http://hallvards.blogspot.com/2006/03/hack-8-explicit-vmt-calls.html
  PSafeCallException = function  (Self: TObject; ExceptObject: TObject;
                         ExceptAddr: Pointer): HResult;
  PAfterConstruction = procedure (Self: TObject);
  PBeforeDestruction = procedure (Self: TObject);
  PDispatch          = procedure (Self: TObject; var Message);
  PDefaultHandler    = procedure (Self: TObject; var Message);
  PNewInstance       = function  (Self: TClass) : TObject;
  PFreeInstance      = procedure (Self: TObject);
  PDestroy           = procedure (Self: TObject; OuterMost: ShortInt);

  PVmt = ^TVmt;
  PClass = ^TClass;

  PFieldInfo = ^TFieldInfo;
  TFieldInfo = packed record
    TypeInfo: PPTypeInfo;
    Offset: Cardinal;
  end;

  PFieldTable = ^TFieldTable;
  TFieldTable = packed record
    X: Word;
    Size: Cardinal;
    Count: Cardinal;
    Fields: array [0..0] of TFieldInfo;
  end;

  // TObject virtual methods' signatures
  TVmt = packed record
    SelfPtr           : TClass;
    IntfTable         : Pointer;
    AutoTable         : Pointer;
    InitTable         : PFieldTable;
    TypeInfo          : PTypeInfo;
    FieldTable        : Pointer;
    MethodTable       : Pointer;
    DynamicTable      : Pointer;
    ClassName         : PShortString;
    InstanceSize      : Cardinal;
    Parent            : PClass;
    {$IFDEF DELPHI2009_UP}
    Equals            : Pointer;
    GetHashCode       : Pointer;
    ToString          : Pointer;
    {$ENDIF}
    SafeCallException : PSafeCallException;
    AfterConstruction : PAfterConstruction;
    BeforeDestruction : PBeforeDestruction;
    Dispatch          : PDispatch;
    DefaultHandler    : PDefaultHandler;
    NewInstance       : PNewInstance;
    FreeInstance      : PFreeInstance;
    Destroy           : PDestroy;
    {UserDefinedVirtuals: array of procedure;}
  end;

  PClassData = ^TClassData;
  TClassData = record
    ClassType: TClass;
    ParentInfo: PPTypeInfo;
    PropCount: SmallInt;
    UnitName: ShortString;
  end;

  PVmtFieldEntry = ^TVmtFieldEntry;
  TVmtFieldEntry = packed record
    FieldOffset: Longword;
    TypeIndex: Word; // index into ClassTab
    Name: ShortString;
  end;

  PVmtFieldTable = ^TVmtFieldTable;
  TVmtFieldTable = packed record
    Count: Word; // Published fields
    ClassTab: PVmtFieldClassTab;
    Entry: packed array[0..0] of TVmtFieldEntry;
  end;

  PAttrEntry = ^TAttrEntry;
  TAttrEntry = packed record
    AttrType: PPTypeInfo;
    AttrCtor: Pointer;
    ArgLen: Word;
    ArgData: array[1..65536 {ArgLen - 2}] of Byte;
  end;

  PAttrData = ^TAttrData;
  TAttrData = record
    Len: Word;
    AttrEntry: array[0..0] of TAttrEntry;
  end;

  PFieldExEntry = ^TFieldExEntry;
  TFieldExEntry = packed record
    Flags: Byte;
    TypeRef: PPTypeInfo;
    Offset: Longword;
    Name: ShortString;
    AttrData: TAttrData;
  end;

  PVmtFieldTableEx = ^TVmtFieldTableEx;
  TVmtFieldTableEx = packed record
    Count: Word;
    Entry: array[0..0] of TFieldExEntry;
  end;

  PVmtMethodParam = ^TVmtMethodParam;
  TVmtMethodParam = packed record
    Flags: Byte;
    ParamType: PPTypeInfo;
    ParOff: Byte; // Parameter location: 0..2 for reg, >=8 for stack
    Name: ShortString;
   {AttrData: TAttrData;}
  end;

  PVmtMethodEntry = ^TVmtMethodEntry;
  TVmtMethodEntry = packed record
    Len: Word;
    CodeAddress: Pointer;
    Name: ShortString;
   {Tail: TVmtMethodEntryTail;} // only exists if Len indicates data here
  end;

  PVmtMethodEntryTail = ^TVmtMethodEntryTail;
  TVmtMethodEntryTail = packed record
    Version: Byte; // =3
    CC: TCallConv;
    ResultType: PPTypeInfo; // nil for procedures
    ParOff: Word; // total size of data needed for stack parameters + 8 (ret-addr + pushed EBP)
    ParamCount: Byte;
    Params: array[0..0] of TVmtMethodParam;
    {AttrData: TAttrData;}
  end;

  PVmtMethodExEntry = ^TVmtMethodExEntry;
  TVmtMethodExEntry = packed record
    Entry: PVmtMethodEntry;
    Flags: Word;
    VirtualIndex: Smallint; // signed word
  end;

  { vmtMethodTable entry in VMT }
  PVmtMethodTable = ^TVmtMethodTable;
  TVmtMethodTable = packed record
    Count: Word;
    Entry: array[0..0] of TVmtMethodEntry;
  end;

  PVmtMethodTableEx = ^TVmtMethodTableEx;
  TVmtMethodTableEx = packed record
    Count: Word;
    Entry: array[0..0] of TVmtMethodExEntry;
  end;

function vmtOfClass(value: TClass): PVmt;

function GetClassData(const value: TClass): PClassData;

implementation

function GetClassData(const value: TClass): PClassData;
begin
  result := Pointer(getTypeData(value.ClassInfo));
end;

function vmtOfClass(value: TClass): PVmt;
begin
   result := pointer(Cardinal(value) - sizeof(TVmt));
end;

end.
