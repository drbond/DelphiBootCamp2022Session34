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

unit vmtBuilder;

interface
uses
  TypInfo, vmtStructure;

const
  NULL_WORD: word = 0;

type
  IBuffer = interface
    procedure add(const data; const size: integer);
    function GetBuffer(out size: integer): pointer;
    function size: integer;
  end;

function newBuffer: IBuffer;

function CreateClassInfo(name: String; parent: TClass; newProperties: Word; out size: integer): PTypeInfo;
function CreateFieldExInfo(name: string; info: PTypeInfo; offset: integer; out size: integer): PFieldExEntry;
function retrieveTypeInfo(const info: PTypeInfo): PPtypeInfo;

implementation
uses
  classes;

const
  MAX_BUFFER_SIZE = 2048;

type
  TBuffer = class(TInterfacedObject, IBuffer)
  private
    FBuffer: array[0..MAX_BUFFER_SIZE - 1] of byte;
    FIndex: integer;
  public
    procedure add(const data; const size: integer);
    function GetBuffer(out size: integer): pointer;
    function size: integer;
  end;

function newBuffer: IBuffer;
begin
  result := TBuffer.Create;
end;

{ Builder functions }

function CreateClassInfo(name: String; parent: TClass; newProperties: Word; out size: integer): PTypeInfo;
var
  buffer: IBuffer;
  kind: TTypeKind;
  shortName: shortString;
  selfPtr: pointer;
  parentInfo: pointer;
  parentData: PClassData;
  propCount: smallint;
begin
  kind := tkClass;
  shortName := UTF8EncodeToShortString(name);
  selfPtr := nil; //this value isn't known yet and has to be changed later
  parentInfo := @vmtOfClass(parent).TypeInfo;
  parentData := GetClassData(parent);
  propCount := parentData.PropCount + newProperties;
  buffer := newBuffer;

  buffer.add(kind, sizeof(TTypeKind));
  buffer.add(shortName, length(name) + 1);
  buffer.add(selfPtr, sizeof(pointer));
  buffer.add(parentInfo, sizeof(pointer));
  buffer.add(propCount, sizeof(smallint));
  buffer.add(parentData.UnitName, length(parentData.UnitName) + 1);

  result := buffer.GetBuffer(size);
end;

function CreateFieldExInfo(name: string; info: PTypeInfo; offset: integer; out size: integer): PFieldExEntry;
var
  buffer: IBuffer;
  flags: byte;
  pInfo: PPTypeInfo;
  shortName: ShortString;
  attrLen: word;
begin
  buffer := newBuffer;
  flags := 0;
  PInfo := retrieveTypeInfo(info);
  shortName := UTF8Encode(name);
  attrLen := sizeof(word); //blank attribute section

  buffer.add(flags, sizeof(byte));
  buffer.add(pInfo, sizeof(pointer));
  buffer.add(offset, sizeof(integer));
  buffer.add(shortName, length(shortName) + 1);
  buffer.add(attrLen, sizeof(word));
  result := buffer.GetBuffer(size);
end;

{ TBuffer }

procedure TBuffer.add(const data; const size: integer);
begin
  system.Move(data, FBuffer[FIndex], size);
  inc(FIndex, size);
end;

function TBuffer.GetBuffer(out size: integer): pointer;
begin
  GetMem(Result, FIndex);
  system.Move(FBuffer[0], result^, FIndex);
  size := FIndex;
end;

function TBuffer.size: integer;
begin
  result := FIndex;
end;

{ Internals }
var
  infoList: TList;

function retrieveTypeInfo(const info: PTypeInfo): PPtypeInfo;
var
  index: integer;
begin
  index := infoList.IndexOf(info);
  if index = -1 then
    index := infoList.Add(info);
  result := @infoList.List[index];
end;

initialization
  infolist := TList.Create;
finalization
  infoList.Free;

end.
