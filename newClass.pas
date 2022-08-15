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

unit newClass;
{$I jedi.inc} // sets up version defines
{$IFNDEF DELPHI5_UP}
{$MESSAGE FATAL This unit requires Delphi 5 or later.}
{$ENDIF}

interface

uses
  typInfo, vmtStructure, classes
{$IFDEF SUPPORTS_GENERICS}, generics.collections {$ENDIF};

type
  TNewField = class
  private
    FData: PFieldExEntry;
    FTypeDataSize: word;
  public
    constructor Create(data: PFieldExEntry; dataSize: word);
    destructor Destroy; override;
    function IsManaged: boolean;
  end;

  TNewFieldList = {$IFDEF SUPPORTS_GENERICS} TObjectList<TNewField>;
  {$ELSE} class(TObjectList)
  protected
    function Get(Index: Integer): TNewField; inline;
    procedure Put(Index: Integer; Item: TNewField); inline;
  public
    function Add(Item: TNewField): Integer;
    inline;
    property Items[Index: Integer]: TNewField read Get write Put; default;
  end;
{$ENDIF}

  TNewClass = class
  private
    FParent: TClass;
    FClassName: string;
    FVMT: array of pointer;
    FNewVirtIndex: Integer;
    FExtraInstanceSize: cardinal;
    FExtraVMs: Integer;
    FNewFields: TNewFieldList;
    FManagedFields: TList;
    function offset: Integer;
    procedure AddNewField(name: string; info: PTypeInfo; size: Integer);
    procedure AddManagedField(info: PTypeInfo);
  public
    constructor Create(parent: TClass; classname: string);
    destructor Destroy; override;

    procedure AddCharField(name: string);
    procedure AddWideCharField(name: string);
    procedure AddAnsiCharField(name: string);

    procedure AddStringField(name: string);
    procedure AddUnicodeStringField(name: string);
    procedure AddAnsiStringField(name: string);

    procedure AddIntegerField(name: string);
    procedure AddOrdField(name: string; kind: TOrdType);
    procedure AddEnumField(name: string; info: PTypeInfo);
    procedure AddFloatField(name: string; kind: TFloatType);
    procedure AddInt64Field(name: string);

    procedure AddVariantField(name: string);
    procedure AddDynArrayField(name: string; info: PTypeInfo);
    procedure AddInterfaceField(name: string; info: PTypeInfo);
    procedure AddRecordField(name: string; info: PTypeInfo);

    procedure AddObjectField(name: string; objectClass: TClass);
    procedure AddClassRefField(name: string; classType: TClass);
    procedure AddPointerField(name: string; info: PTypeInfo);

    function classPtr: TClass;
  end;

const
  VMT_SIZE = sizeof(TVmt) div sizeof(pointer);

  // function UserDefinedVirtualCount(value: TClass): cardinal;
{$IFDEF NO_JCL}
function GetVirtualMethodCount(AClass: TClass): Integer;
{$ENDIF}

{ ****************************************************************************** }
implementation

uses
{$IFNDEF NO_JCL}
  JclSysUtils,
{$ENDIF}
  vmtBuilder;

{$IFDEF NO_JCL}

function GetVirtualMethodCount(AClass: TClass): Integer;
var
  BeginVMT: Integer;
  EndVMT: Integer;
  TablePointer: Integer;
  I: Integer;
begin
  BeginVMT := Integer(AClass);

  // Scan the offset entries in the class table for the various fields,
  // namely vmtIntfTable, vmtAutoTable, ..., vmtDynamicTable
  // The last entry is always the vmtClassName, so stop once we got there
  // After the last virtual method there is one of these entries.

  EndVMT := PInteger(Integer(AClass) + vmtClassName)^;
  // Set iterator to first item behind VMT table pointer
  I := vmtSelfPtr + sizeof(pointer);
  repeat
    TablePointer := PInteger(Integer(AClass) + I)^;
    if (TablePointer <> 0) and (TablePointer >= BeginVMT) and
      (TablePointer < EndVMT) then
      EndVMT := Integer(TablePointer);
    Inc(I, sizeof(pointer));
  until I >= vmtClassName;

  Result := (EndVMT - BeginVMT) div sizeof(pointer);
end;
{$ENDIF}
{ TNewClass }

procedure TNewClass.AddAnsiCharField(name: string);
begin
  AddNewField(name, TypeInfo(ansiChar), 1);
end;

procedure TNewClass.AddWideCharField(name: string);
begin
  AddNewField(name, TypeInfo(wideChar), 2);
end;

procedure TNewClass.AddCharField(name: string);
begin
{$IFNDEF UNICODE}
  AddAnsiCharField(name);
{$ELSE}
  AddWideCharField(name);
{$ENDIF}
end;

procedure TNewClass.AddDynArrayField(name: string; info: PTypeInfo);
begin
  assert(info.kind = tkDynArray);
  AddManagedField(info);
  AddNewField(name, info, sizeof(pointer));
end;

procedure TNewClass.AddRecordField(name: string; info: PTypeInfo);
begin
  assert(info.kind = tkRecord);
  if (GetTypeData(info).ManagedFldCount > 0) then
    AddManagedField(info);
  AddNewField(name, info, GetTypeData(info).RecSize);
end;

procedure TNewClass.AddAnsiStringField(name: string);
begin
  AddManagedField(TypeInfo(ansiString));
  AddNewField(name, TypeInfo(ansiString), sizeof(pointer));
end;

procedure TNewClass.AddUnicodeStringField(name: string);
begin
  AddManagedField(TypeInfo(unicodeString));
  AddNewField(name, TypeInfo(unicodeString), sizeof(pointer));
end;

procedure TNewClass.AddStringField(name: string);
begin
{$IFNDEF UNICODE}
  AddAnsiStringField(name);
{$ELSE}
  AddUnicodeStringField(name);
{$ENDIF}
end;

procedure TNewClass.AddVariantField(name: string);
begin
  AddManagedField(TypeInfo(variant));
  AddNewField(name, TypeInfo(variant), sizeof(variant));
end;

procedure TNewClass.AddInt64Field(name: string);
begin
  AddNewField(name, TypeInfo(int64), sizeof(int64));
end;

procedure TNewClass.AddInterfaceField(name: string; info: PTypeInfo);
begin
  assert(info.kind = tkInterface);
  AddManagedField(info);
  AddNewField(name, info, sizeof(IInterface));
end;

procedure TNewClass.AddObjectField(name: string; objectClass: TClass);
begin
  AddNewField(name, objectClass.ClassInfo, sizeof(TObject));
end;

procedure TNewClass.AddClassRefField(name: string; classType: TClass);
begin
  AddNewField(name, classType.ClassInfo, sizeof(TClass));
end;

procedure TNewClass.AddPointerField(name: string; info: PTypeInfo);
begin
  assert(info.kind = tkPointer);
  AddNewField(name, info, sizeof(pointer));
end;

const
  ORD_SIZES: array [TOrdType] of byte = (1, 1, 2, 2, 4, 4);

procedure TNewClass.AddEnumField(name: string; info: PTypeInfo);
var
  size: Integer;
  data: PTypeData;
begin
  assert(info.kind = tkEnumeration);
  data := GetTypeData(info);
  if data.BaseType^ = TypeInfo(boolean) then
    size := sizeof(boolean)
  else
    size := ORD_SIZES[GetTypeData(data.BaseType^).OrdType];
  AddNewField(name, info, size);
end;

procedure TNewClass.AddIntegerField(name: string);
begin
  AddOrdField(name, otSlong);
end;

{$WARN USE_BEFORE_DEF OFF}
procedure TNewClass.AddOrdField(name: string; kind: TOrdType);
var
  info: PTypeInfo;
begin
  case kind of
    otSByte:
      info := TypeInfo(shortInt);
    otUByte:
      info := TypeInfo(byte);
    otSWord:
      info := TypeInfo(smallInt);
    otUWord:
      info := TypeInfo(word);
    otSLong:
      info := TypeInfo(Integer);
    otULong:
      info := TypeInfo(cardinal);
  else
    assert(false);
  end;
  AddNewField(name, info, ORD_SIZES[kind]);
end;

const
  FLOAT_SIZES: array [TFloatType] of byte =
    (sizeof(single), sizeof(double), sizeof(extended), sizeof(comp), sizeof
      (currency));

procedure TNewClass.AddFloatField(name: string; kind: TFloatType);
var
  info: PTypeInfo;
begin
  case kind of
    ftSingle:
      info := TypeInfo(single);
    ftDouble:
      info := TypeInfo(double);
    ftExtended:
      info := TypeInfo(extended);
    ftComp:
      info := TypeInfo(comp);
    ftCurr:
      info := TypeInfo(currency);
  else
    assert(false);
  end;
  AddNewField(name, info, FLOAT_SIZES[kind]);
end;
{$WARN USE_BEFORE_DEF ON}

procedure TNewClass.AddManagedField(info: PTypeInfo);
var
  field: PFieldInfo;
begin
  new(field);
  field.TypeInfo := retrieveTypeInfo(info);
  field.offset := self.offset;
  FManagedFields.Add(field);
end;

procedure TNewClass.AddNewField(name: string; info: PTypeInfo; size: Integer);
var
  entry: PFieldExEntry;
  bufferSize: Integer;
begin
  assert(size > 0);
  entry := CreateFieldExInfo(name, info, self.offset, bufferSize);
  FNewFields.Add(TNewField.Create(entry, bufferSize));
  Inc(FExtraInstanceSize, size);
end;

function TNewClass.classPtr: TClass;
var
  overlay, overlayParent: PVmt;
  reader, writer: PPointer;
  I, bufferSize: Integer;
  mfOffset, ftOffset, nameOffset: Integer;
  name: ShortString;
  buffer: IBuffer;
  x: word;
  dummySize: cardinal;
  nullPtr: pointer;
  newVMT: pointer;
begin
  setLength(FVMT, VMT_SIZE + GetVirtualMethodCount(FParent) + FExtraVMs);

  // copy the FParent's built-in metadata
  overlayParent := vmtOfClass(FParent);
  overlay := @FVMT[0];
  overlay^ := overlayParent^;

  // set up user-defined virtuals
  reader := PPointer(FParent);
  writer := @overlay.Destroy;
  Inc(writer);
  for I := 1 to GetVirtualMethodCount(FParent) do
  begin
    writer^ := reader^;
    Inc(reader);
    Inc(writer);
  end;

  buffer := newBuffer;
  buffer.Add(FVMT[0], length(FVMT) * sizeof(pointer));
  if FManagedFields.Count > 0 then
  begin
    mfOffset := buffer.size;
    // first two values are set up this way so you can overlay a TTypeInfo
    // on the record and get (tkRecord, 0)
    x := ord(tkRecord);
    dummySize := 0;
    buffer.Add(x, sizeof(word));
    buffer.Add(dummySize, sizeof(cardinal));
    buffer.Add(FManagedFields.Count, sizeof(cardinal));
    for I := 0 to FManagedFields.Count - 1 do
       buffer.Add(PFieldInfo(FManagedFields[I])^, sizeof(TFieldInfo));
  end
  else
     mfOffset := 0;

  {$IFDEF DELPHI2010_UP}
  if FNewFields.Count > 0 then
  begin
     ftOffset := buffer.size;
     buffer.add(NULL_WORD, sizeof(word));
     nullPtr := nil;
     buffer.add(nullPtr, sizeof(pointer));
     buffer.add(FNewFields.Count, sizeof(word));
     for I := 0 to FNewFields.Count - 1 do
       buffer.add(FNewFields[i].FData^, FNewFields[i].FTypeDataSize);
  end
  else {$ENDIF}
    ftOffset := 0;

  nameOffset := buffer.size;

  // place class name pointer at the end of the list
{$IFDEF DELPHI2009_UP}
  name := UTF8EncodeToShortString(FClassName);
{$ELSE}
  name := shortString(FClassName);
{$ENDIF}
  buffer.add(name, length(name) + 1);

  newVMT := buffer.GetBuffer(bufferSize);
  overlay := pointer(newVMT);

  // set up the VMT with new information
  // overlay.SelfPtr := newClass;
  overlay.IntfTable := nil;
  overlay.AutoTable := nil;
  if mfOffset > 0 then
    integer(overlay.InitTable) := integer(newVMT) + mfOffset
  else overlay.InitTable := nil;
  if ftOffset > 0 then
    integer(overlay.FieldTable) := integer(newVMT) + ftOffset
  else overlay.FieldTable := nil;
  overlay.MethodTable := nil;
  overlay.DynamicTable := nil;
  integer(overlay.classname) := integer(newVMT) + nameOffset;
  overlay.InstanceSize := overlayParent.InstanceSize + FExtraInstanceSize;
  new(overlay.parent);
  overlay.parent^ := FParent;
  overlay.TypeInfo := vmtBuilder.CreateClassInfo
    (classname, FParent, 0, bufferSize);
{$IFDEF DELPHI2006_UP}
  // keep FastMM from complaining about all this garbage
  RegisterExpectedMemoryLeak(newVMT);
  RegisterExpectedMemoryLeak(FVMT);
  RegisterExpectedMemoryLeak(overlay.parent);
  RegisterExpectedMemoryLeak(overlay.TypeInfo);
{$ENDIF}
  integer(result) := integer(overlay) + sizeof(TVmt);
  getTypeData(overlay.TypeInfo).ClassType := pointer(result);
end;

constructor TNewClass.Create(parent: TClass; classname: string);
begin
  FParent := parent;
  FClassName := classname;
  FNewFields := TNewFieldList.Create;
  FManagedFields := TList.Create;
end;

destructor TNewClass.Destroy;
var
  field: pointer;
begin
  FNewFields.Free;
  for field in FManagedFields do
    FreeMem(field);
  FManagedFields.Free;
  inherited Destroy;
end;

function TNewClass.offset: Integer;
begin
  Result := FParent.InstanceSize + integer(FExtraInstanceSize);
{$IFDEF DELPHI2009_UP}
  dec(Result, sizeof(pointer));
{$ENDIF}
end;

{ TNewField }

constructor TNewField.Create(data: PFieldExEntry; dataSize: word);
begin
  FData := data;
  FTypeDataSize := dataSize;
end;

destructor TNewField.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

function TNewField.IsManaged: boolean;
const
  MANAGED_TYPES = [tkString, tkLString, tkWString, tkVariant, tkInterface,
    tkDynArray, tkUString];
begin
  Result := FData.TypeRef^.kind in MANAGED_TYPES;
end;
{$IFNDEF SUPPORTS_GENERICS}
{ TNewFieldList }

function TNewFieldList.Add(Item: TNewField): Integer;
begin
  inherited Add(pointer(Item.ID));
end;

function TNewFieldList.Get(Index: Integer): TNewField;
begin
  Result.ID := TSdlTextureID( inherited Get(index));
end;

procedure TNewFieldList.Put(Index: Integer; Item: TNewField);
begin
  inherited Put(index, pointer(Item.ID));
end;
{$ENDIF}

end.
