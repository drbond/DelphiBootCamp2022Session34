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

unit vmtview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,
  TypInfo, vmtStructure, newClass;

type
  TClassViewer = class(TForm)
    lstHierarchy: TListBox;
    StaticText1: TStaticText;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    txtPropCount: TEdit;
    txtUnit: TEdit;
    TabSheet2: TTabSheet;
    lstInterface: TListView;
    TabSheet3: TTabSheet;
    lstInit: TListView;
    TabSheet4: TTabSheet;
    lstPublishedFields: TListView;
    TabSheet5: TTabSheet;
    lstFields: TListView;
    TabSheet6: TTabSheet;
    lstPublishedMethods: TListView;
    Al: TTabSheet;
    lstMethods: TListView;
    StaticText8: TStaticText;
    txtClassName: TEdit;
    StaticText9: TStaticText;
    txtInstanceSize: TEdit;
    lstVirtuals: TListView;
    StaticText10: TStaticText;
    procedure FormShow(Sender: TObject); virtual;
    procedure lstHierarchyClick(Sender: TObject);
  private
    procedure DisplayGeneral(const aVmt: PVmt);
    procedure DisplayInterfaces(const aClass: TClass);
    procedure DisplayInit(const aVmt: PVmt);
    procedure DisplayClassData(const aClass: TClass);
    procedure DisplayFieldData(const aVmt: PVmt);
    procedure DisplayMethodData(const aVmt: PVmt);
  private
    procedure DisplayClass(const aClass: TClass);
  public
    procedure LoadClass(const aClass: TClass); overload;
    procedure LoadClass(const aObject: TObject); overload;
  end;

var
  ClassViewer: TClassViewer;

implementation

uses
  math {$IFNDEF NO_JCL},
 JclSysUtils{$ENDIF};

{$R *.dfm}

procedure TClassViewer.DisplayClassData(const aClass: TClass);
var
  LClassInfo: PTypeInfo;
  data: PClassData;
begin
  LClassInfo := aClass.ClassInfo;
  if not assigned(LClassInfo) then
  begin
    txtPropCount.Text := '';
    txtUnit.Text := '';
    Exit;
  end;

  Data := getClassData(aClass);
  assert(data.ClassType = aClass);
  txtPropCount.Text := intToStr(data.PropCount);
  txtUnit.Text := string(data.UnitName);
end;

procedure TClassViewer.DisplayFieldData(const aVmt: PVmt);

  function GetNextPublishedField(PublishedField: PVmtFieldEntry): PVmtFieldEntry;
  const
    FIELD_RECORD_LENGTH = sizeof(cardinal) + sizeof(word) + 1;
  begin
    Result := PublishedField;
    if Assigned(Result) then
      Inc(PByte(Result), FIELD_RECORD_LENGTH + Length(Result.Name));
  end;

  function GetAttributePtr(FieldEx: PFieldExEntry): PAttrData;
  const
    FIELDEX_RECORD_LENGTH = sizeof(Byte) + sizeof(pointer) + sizeof(Cardinal) + 1;
  begin
    result := pointer(FieldEx);
    if assigned(result) then
      Inc(PByte(Result), FIELDEX_RECORD_LENGTH + length(FieldEx.Name));
  end;

  function GetNextAttribute(attribute: PAttrEntry): PAttrEntry;
  const
    ATTRIBUTE_RECORD_LENGTH = (sizeof(pointer) * 2) + sizeof(word);
  begin
    result := attribute;
    if assigned(result) then
      inc(PByte(Result), ATTRIBUTE_RECORD_LENGTH + attribute.ArgLen);
  end;

  function GetNextFieldEx(FieldEx: PFieldExEntry): PFieldExEntry;
  var
    attributes: PAttrData;
  begin
    result := fieldEx;
    if assigned(FieldEx) then
    begin
      attributes := GetAttributePtr(FieldEx);
      result := pointer(integer(PByte(attributes)) + attributes.Len);
    end;
  end;

var
  table: PVmtFieldTable;
  tableEx: PVmtFieldTableEx;
  i: integer;
  item: TListItem;
  entry: PVmtFieldEntry;
  exEntry: PFieldExEntry;
begin
  table := aVmt.FieldTable;
  lstPublishedFields.Clear;
  lstFields.Clear;
  if not assigned(table) then
    Exit;

  entry := @table.Entry[0];
  for I := 0 to table.Count - 1 do
  begin
    item := lstPublishedFields.Items.Add;
    item.Caption := string(entry.Name);
    item.SubItems.Add(table.ClassTab.ClassRef[entry.TypeIndex].ClassName);
    item.SubItems.Add('$' + intToHex(entry.FieldOffset, 2));
    entry := GetNextPublishedField(entry);
  end;

  tableEx := pointer(entry);
  exEntry := @tableEx.Entry[0];
  for I := 0 to tableEx.Count - 1 do
  begin
    item := lstFields.Items.Add;
    item.Caption := string(exEntry.Name);
    item.SubItems.Add(string(exEntry.TypeRef^.Name));
    item.SubItems.Add('$' + intToHex(exEntry.Offset, 2));
    item.SubItems.Add(intToStr(exEntry.Flags));
    item.SubItems.Add(intToStr(GetAttributePtr(exEntry).Len - sizeof(word) ));
    exEntry := GetNextFieldEx(exEntry);
  end;
end;

const VMT_METHOD_LENGTH = sizeof(word) + sizeof(pointer) + 1;
function GetEntryTail(entry: PVmtMethodEntry): PVmtMethodEntryTail;
begin
  result := pointer(entry);
  if assigned(Result) then
    inc(PByte(result), VMT_METHOD_LENGTH + length(entry.Name));
end;

function GetNextPublishedMethod(entry: PVmtMethodEntry): PVmtMethodEntry;
begin
  result := entry;
  if assigned(result) then
    inc(PByte(result), entry.Len);
end;

const VMT_METHOD_EX_LENGTH = sizeof(pointer) + sizeof(word) + sizeof(smallint);
function GetNextPublishedMethodEx(entry: PVmtMethodExEntry): PVmtMethodExEntry;
begin
  result := entry;
  if assigned(result) then
    inc(PByte(result), VMT_METHOD_EX_LENGTH);
end;

procedure TClassViewer.DisplayMethodData(const aVmt: PVmt);
var
  table: PVmtMethodTable;
  tableEx: PVmtMethodTableEx;
  i: integer;
  item: TListItem;
  entry: PVmtMethodEntry;
  entryTail: PVmtMethodEntryTail;
  exEntry: PVmtMethodExEntry;
begin
  table := aVmt.MethodTable;
  lstPublishedMethods.Clear;
  lstMethods.Clear;
  if not assigned(table) then
    Exit;

  entry := @table.Entry[0];
  for I := 0 to table.Count - 1 do
  begin
    item := lstPublishedMethods.Items.Add;
    item.Caption := string(entry.Name);
    item.SubItems.Add('$' + intToHex(integer(entry.CodeAddress), 8));
    if entry.Len > (VMT_METHOD_LENGTH + length(entry.Name)) then
    begin
      entryTail := GetEntryTail(entry);
      item.SubItems.Add(GetEnumName(TypeInfo(TCallConv), ord(entryTail.CC)));
      if assigned(entryTail.ResultType) then
        item.SubItems.Add(string(entryTail.ResultType^.Name))
      else
        item.SubItems.Add('');
      item.SubItems.Add(intToStr(entryTail.ParOff));
      item.SubItems.AddObject(intToSTr(entryTail.ParamCount), pointer(entryTail));
    end;
    entry := GetNextPublishedMethod(entry);
  end;

  tableEx := pointer(entry);
  exEntry := @tableEx.Entry[0];
  for I := 0 to tableEx.Count - 1 do
  begin
    item := lstMethods.Items.Add;
    item.Caption := string(exEntry.entry.Name);
    item.SubItems.Add('$' + intToHex(integer(exEntry.entry.CodeAddress), 8));
    if exEntry.entry.Len > (VMT_METHOD_LENGTH + length(exEntry.entry.Name)) then
    begin
      entryTail := GetEntryTail(exEntry.entry);
      item.SubItems.Add(GetEnumName(TypeInfo(TCallConv), ord(entryTail.CC)));
      if assigned(entryTail.ResultType) then
        item.SubItems.Add(string(entryTail.ResultType^.Name))
      else
        item.SubItems.Add('(None)');
      item.SubItems.Add(intToStr(entryTail.ParOff));
      item.SubItems.AddObject(intToSTr(entryTail.ParamCount), pointer(entryTail));
    end;
    exEntry := GetNextPublishedMethodEx(exEntry);
  end;
end;

procedure TClassViewer.DisplayGeneral(const aVmt: PVmt);

  function findOriginal(base: TClass; address: pointer; index: integer): TClass;
  begin
    result := nil;
    repeat
      if PPointer(integer(pointer(base)) + (index * sizeof(pointer)))^ = PPointer(address)^ then
      begin
        result := base;
        base := base.ClassParent;
      end
      else break;
    until base = nil;
  end;

  function GetMethodExTable(aClass: TClass): PVmtMethodTableEx;
  var
    table: PVmtMethodTable;
    entry: PVmtMethodEntry;
    i: integer;
  begin
    table := vmtOfClass(aClass).MethodTable;
    entry := @table.Entry[0];
    for i := 0 to table.Count - 1 do
      entry := GetNextPublishedMethod(entry);
    result := pointer(entry);
  end;

  function findName(aClass: TClass; address: PPointer): string;
  var
    methodExTable: PVmtMethodTableEx;
    entry: PVmtMethodExEntry;
    i: integer;
  begin
    result := '(No RTTI)';
    methodExTable := GetMethodExTable(aClass);
    entry := @methodExTable.Entry[0];
    for I := 0 to methodExTable.Count - 1 do
    begin
      if entry.Entry.CodeAddress = address^ then
        exit(string(entry.Entry.Name))
      else entry := GetNextPublishedMethodEx(entry);
    end;
  end;

const
  BUILT_IN = 11;
var
  count: integer;
  current: pointer;
  index: integer;
  item: TListItem;
  name: string;
  baseClass: TClass;
begin
  txtClassName.Text := string(aVmt.ClassName^);
  txtInstanceSize.Text := intToStr(aVmt.InstanceSize);
  count := GetVirtualMethodCount(aVmt.SelfPtr);
  lstVirtuals.Clear;
  current := @aVmt.Parent; //right before the virtuals start
  for index := -BUILT_IN to Count - 1 do
  begin
    current := pointer(integer(current) + sizeof(pointer));
    item := lstVirtuals.Items.Add;
    item.Caption := intToStr(index);
    item.SubItems.Add('$' + intToHex(integer(current), 8));
    baseClass := findOriginal(aVmt.SelfPtr, current, index);
    item.SubItems.Add(baseClass.className);
    name := aVmt.SelfPtr.MethodName(PPointer(current)^);
    if name = '' then
      name := findName(baseClass, current);
    item.SubItems.Add(name);
  end;
end;

procedure TClassViewer.DisplayInit(const aVmt: PVmt);
var
  ft: PFieldTable;
  i: integer;
  info: TFieldInfo;
  item: TListItem;
begin
  lstInit.Clear;
  ft := aVmt.InitTable;
  if not assigned(ft) then
    Exit;

  for i := 0 to FT.Count - 1 do
  begin
    item := lstInit.Items.Add;
    info := ft.Fields[i];
    item.Caption := string(info.TypeInfo^.Name);
    item.SubItems.Add(TypInfo.GetEnumName(TypeInfo(TTypeKind), ord(info.TypeInfo^.Kind)));
    item.SubItems.Add('$' + intToHex(info.Offset, 2));
  end;
end;

procedure TClassViewer.DisplayInterfaces(const aClass: TClass);
var
  IntfTable: PInterfaceTable;
  i: integer;
  item: TListItem;
  intfEntry: pInterfaceEntry;
begin
  lstInterface.Clear;
  IntfTable := aClass.GetInterfaceTable;
  if assigned(IntfTable) then
  begin
    for I := 0 to IntfTable.EntryCount - 1 do
    begin
      intfEntry := @IntfTable.Entries[i];
      item := lstInterface.Items.Add;
      item.Caption := GUIDToString(intfEntry.IID);
      item.SubItems.Add('$' + IntToHex(integer(intfEntry.VTable), 8));
      item.SubItems.Add('$' + IntToHex(intfEntry.IOffset, 2));
      item.SubItems.Add(intToStr(intfEntry.ImplGetter));
    end;
  end;
end;

procedure TClassViewer.DisplayClass(const aClass: TClass);
var
  VMT: PVmt;
begin
  vmt := vmtOfClass(aClass);
  DisplayGeneral(vmt);
  DisplayInterfaces(aClass);
  DisplayInit(vmt);
  DisplayClassData(aClass);
  DisplayFieldData(vmt);
  DisplayMethodData(vmt);
end;

procedure TClassViewer.FormShow(Sender: TObject);
var
  ProcRef : TProc; //Reference to an interface
  FuncRef : TFunc<String>; //Reference to the same interface
  ProcRef2 : TProc; //Reference to an interface
  InterfaceRef : IInterface absolute ProcRef; // Absolute allows another variable at
                                              // the same memory address of a variable
                                              // that already exists, in this case a reference.
  x : String;
  y : Integer;
begin
  ReportMemoryLeaksOnShutdown := true;
  x := 'Hello World';
  y := Integer(addr(x));
  ShowMessage('Address of local variable x = ' + IntToStr(y));
  ProcRef := Procedure Begin ShowMessage('ProcRef call: ClassName = ' + Sender.ClassName) End;
  ProcRef2 := Procedure Begin ShowMessage('ProcRef2 call ClassName = ' + Sender.ClassName {+ (InterfaceRef As TObject).ToString}) End;
  FuncRef := Function : String Begin Result := 'ClassName = ' + Sender.ClassName {+ ' x = ' + x {+ ' address of x = ' + IntToStr(y)} End;
  ShowMessage(FuncRef());
  ProcRef();
  ProcRef2();
  LoadClass(InterfaceRef As TObject);  //As TObject works for Delphi 2010 and onwards
end;

procedure TClassViewer.LoadClass(const aClass: TClass);
var
  current: TClass;
  currString: string;
  currWidth: integer;
begin
  lstHierarchy.Clear;
  current := aClass;
  while current <> nil do
  begin
    lstHierarchy.AddItem(current.ClassName, pointer(current));
    current := current.ClassParent;
  end;

  currWidth := 0;
  for currString in lstHierarchy.Items do
    currWidth := max(currWidth, lstHierarchy.Canvas.TextWidth(currString));
  lstHierarchy.ScrollWidth := currWidth + 2;

  lstHierarchy.Selected[0] := true;
  lstHierarchyClick(self);
end;

procedure TClassViewer.lstHierarchyClick(Sender: TObject);
begin
  displayClass(TClass(pointer(lstHierarchy.Items.Objects[lstHierarchy.ItemIndex])));
end;

procedure TClassViewer.LoadClass(const aObject: TObject);
begin
  LoadClass(aObject.ClassType);
end;

end.
