{ *******************************************************************************
  *                                                                             *
  *          Delphi Standard Template Library                                   *
  *                                                                             *
  *          (C)Copyright Jimx 2011                                             *
  *                                                                             *
  *          http://delphi-standard-template-library.googlecode.com             *
  *                                                                             *
  *******************************************************************************
  *  This file is part of Delphi Standard Template Library.                     *
  *                                                                             *
  *  Delphi Standard Template Library is free software:                         *
  *  you can redistribute it and/or modify                                      *
  *  it under the terms of the GNU General Public License as published by       *
  *  the Free Software Foundation, either version 3 of the License, or          *
  *  (at your option) any later version.                                        *
  *                                                                             *
  *  Delphi Standard Template Library is distributed                            *
  *  in the hope that it will be useful,                                        *
  *  but WITHOUT ANY WARRANTY; without even the implied warranty of             *
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
  *  GNU General Public License for more details.                               *
  *                                                                             *
  *  You should have received a copy of the GNU General Public License          *
  *  along with Delphi Standard Template Library.                               *
  *  If not, see <http://www.gnu.org/licenses/>.                                *
  ******************************************************************************* }
unit DSTL.Types;

interface

uses SysUtils, Generics.Defaults, Generics.Collections;

type
  TBaseObject = TVarRec;
  PObj = ^TBaseObject;
  ArrObject<T> = array [0 .. MaxInt div sizeof(TBaseObject) - 1] of T;

function compare(obj1, obj2: TBaseObject): integer;

implementation

function compare(obj1, obj2: TBaseObject): integer;
begin
  result := 0;
  assert(obj1.VType = obj2.VType);
  case obj1.VType of
    vtInteger:
      result := obj1.VInteger - obj2.VInteger;
    vtBoolean:
      result := Ord(obj1.VBoolean) - Ord(obj2.VBoolean);
    vtChar:
      result := Ord(obj1.VChar) - Ord(obj2.VChar);
    vtString:
      result := CompareStr(string(obj1.VString^), string(obj2.VString^));
    vtPointer:
      result := integer(obj1.VPointer) - integer(obj2.VPointer);
    vtPChar:
      result := integer(obj1.VPChar) - integer(obj2.VPChar);
    vtObject:
      result := integer(obj1.VObject) - integer(obj2.VObject);
    vtClass:
      result := integer(obj1.VClass) - integer(obj2.VClass);
    vtWideChar:
      result := Ord(obj1.VWideChar) - Ord(obj2.VWideChar);
    vtPWideChar:
      result := integer(obj1.VPWideChar) - integer(obj2.VPWideChar);
    vtAnsiString:
      result := CompareStr(String(obj1.VAnsiString), String(obj2.VAnsiString));
    vtWideString:
      if WideString(obj1.VWideString) < WideString(obj2.VWideString) then
        result := -1
      else if WideString(obj1.VWideString) = WideString(obj2.VWideString) then
        result := 0
      else
        result := 1;
{$IFDEF VER220}
    vtUnicodeString:
      result := CompareStr(String(obj1.VUnicodeString),
        String(obj2.VUnicodeString));
{$ENDIF}
  end;
end;

end.
