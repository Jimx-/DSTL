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
unit DSTL.STL.Deque;

interface

uses
  Windows, Generics.Defaults, SysUtils,
  DSTL.Types, DSTL.STL.Iterator, DSTL.STL.Sequence, DSTL.Exception, DSTL.STL.Alloc,
  DSTL.STL.DequeMap, DSTL.Algorithm;

const
  defaultBufSize = 32;

type
  EDSTLBufferSizeTooLargeException = class(Exception)
  end;

  TDeque<T> = class(TSequence<T>)
  protected
    allocator: IAllocator<T>;

    buf_size: TSizeType;
    map: TDequeMapNode<T>;
    fstart, ffinish: TIterator<T>;

    procedure iadvance(var Iterator: TIterator<T>); override;
    procedure iadvance_by(var Iterator: TIterator<T>;n: integer);
    procedure iretreat(var Iterator: TIterator<T>); override;
    procedure iretreat_by(var Iterator: TIterator<T>;n: integer);
    function iget(const Iterator: TIterator<T>): T; override;
    procedure iput(const Iterator: TIterator<T>; const obj: T); override;
    function iequals(const iter1, iter2: TIterator<T>): boolean; override;
    function idistance(const iter1, iter2: TIterator<T>): integer;  override;
    function get_item(idx: integer): T;
    procedure set_item(idx: integer; const value: T);
    function get_buf_size: TSizeType;
    procedure set_buf_size(const value: TSizeType);
    procedure set_node(var it: TIterator<T>; node: TDequeMapNode<T>);
    procedure create_map;
    procedure push_front_aux(const obj: T);
    procedure push_back_aux(const obj: T);
    function pop_back_aux: T;
    function pop_front_aux: T;
    function reserve_elements_at_front(n: integer): TIterator<T>;
    function reserve_elements_at_back(n: integer): TIterator<T>;
    function insert_aux(Iterator: TIterator<T>; const obj: T): TIterator<T>;  overload;
    procedure insert_aux(position: TIterator<T>; first, last: TIterator<T>; n: integer); overload;
    procedure fill_insert(position: TIterator<T>; n: integer; const obj: T);
    procedure insert_aux(position: TIterator<T>; n: integer; const obj: T); overload;
  public

    constructor Create;  overload;
    constructor Create(alloc: IAllocator<T>); overload;
    constructor Create(n: integer; value: T); overload;
    constructor Create(first, last: TIterator<T>); overload;
    constructor Create(x: TDeque<T>); overload;
    destructor Destroy; override;
    procedure assign(first, last: TIterator<T>); overload;
    procedure assign(n: integer; u: T); overload;
    procedure add(const obj: T); override;
    procedure remove(const obj: T); override;
    procedure clear; override;
    function start: TIterator<T>; override;
    function finish: TIterator<T>; override;
    function front: T; override;
    function back: T; override;
    function capacity: integer;
    function max_size: integer; override;
    procedure reserve(const n: integer);
    procedure resize(const n: integer); overload;
    procedure resize(const n: integer; const x: T); overload;
    function size: integer; override;
    function empty: boolean; override;
    function at(const idx: integer): T; override;
    function pop_front: T; override;
    procedure push_front(const obj: T);override;
    function pop_back: T; override;
    procedure push_back(const obj: T); override;
    function insert(Iterator: TIterator<T>; const obj: T): TIterator<T>; overload;
    procedure insert(position: TIterator<T>; n: integer; const obj: T); overload;
    procedure insert(position: TIterator<T>; first, last: TIterator<T>); overload;
    function erase(it: TIterator<T>): TIterator<T>; overload;
    function erase(_start, _finish: TIterator<T>): TIterator<T>; overload;
    procedure swap(var dqe: TDeque<T>);

    property items[idx: integer]: T read get_item write set_item; default;
    function get_allocator: IAllocator<T>;
    property buffer_size: TSizeType read get_buf_size write set_buf_size;
  end;

implementation

{ ******************************************************************************
  *                                                                            *
  *                                TDeque                                     *
  *                                                                            *
  ****************************************************************************** }
constructor TDeque<T>.Create;
begin
  allocator := TAllocator<T>.Create;
  buf_size := defaultBufSize;
  create_map;
  fstart.handle := Self;
  ffinish.handle := Self;
end;

constructor TDeque<T>.Create(alloc: IAllocator<T>);
begin
  allocator := alloc;
  buf_size := defaultBufSize;
  create_map;
  fstart.handle := Self;
  ffinish.handle := Self;
end;

constructor TDeque<T>.Create(n: integer; value: T);
begin
  allocator := TAllocator<T>.Create;
  buf_size := defaultBufSize;
  assign(n, value);
  fstart.handle := Self;
  ffinish.handle := Self;
end;

constructor TDeque<T>.Create(first, last: TIterator<T>);
begin
  allocator := TAllocator<T>.Create;
  buf_size := defaultBufSize;
  assign(first, last);
  fstart.handle := Self;
  ffinish.handle := Self;
end;

constructor TDeque<T>.Create(x: TDeque<T>);
begin
  allocator := TAllocator<T>.Create;
  buf_size := defaultBufSize;
  assign(x.start, x.finish);
  fstart.handle := Self;
  ffinish.handle := Self;
end;

destructor TDeque<T>.Destroy;
begin
end;

procedure TDeque<T>.iadvance(var Iterator: TIterator<T>);
begin
  inc(Iterator.cur);
  if Iterator.cur = Iterator.last then
  begin
    set_node(Iterator, Iterator.bnode.next);
    Iterator.cur := Iterator.first;
  end;
end;

procedure TDeque<T>.iadvance_by(var Iterator: TIterator<T>;n: integer);
var
  i: integer;
begin
  for i := 1 to n do
    iadvance(Iterator);
end;

procedure TDeque<T>.iretreat(var Iterator: TIterator<T>);
begin
  if Iterator.cur = Iterator.first then
  begin
    set_node(Iterator, Iterator.bnode.prev);
    Iterator.cur := Iterator.last;
  end;
  dec(Iterator.cur);
end;

procedure TDeque<T>.iretreat_by(var Iterator: TIterator<T>;n: integer);
var
  i: integer;
begin
  for i := 1 to n do
    iretreat(Iterator);
end;

function TDeque<T>.iget(const Iterator: TIterator<T>): T;
begin
  result := Iterator.bnode.buf[Iterator.cur];
end;

procedure TDeque<T>.iput(const Iterator: TIterator<T>; const obj: T);
begin
  Iterator.bnode.buf[Iterator.cur] := obj;
end;

function TDeque<T>.iequals(const iter1, iter2: TIterator<T>): boolean;
begin
  result := (iter1.bnode = iter2.bnode) and (iter1.cur = iter2.cur);
end;

function TDeque<T>.idistance(const iter1, iter2: TIterator<T>): integer;
var
  dist: integer;
  iter: TIterator<T>;
begin
  dist := 0;
  iter := iter1;
  while iter <> iter2 do
  begin
    iadvance(iter);
    inc(dist);
  end;
  Result := dist;
end;

function TDeque<T>.get_item(idx: integer): T;
var
  it: TIterator<T>;
begin
  if (idx >= size) or (idx < 0) then dstl_raise_exception(E_OUT_OF_BOUND);
  it := fstart;
  while idx > 0 do
  begin
    iadvance(it);
    dec(idx);
  end;
  Result := it.bnode.buf[it.cur];
end;

procedure TDeque<T>.set_item(idx: integer; const value: T);
var
  it: TIterator<T>;
begin
  it := fstart;
  while idx > 0 do
  begin
    iadvance(it);
    dec(idx);
  end;
  it.bnode.buf[it.cur] := value;
end;

function TDeque<T>.get_buf_size: TSizeType;
begin
  Result := Self.buf_size;
end;

procedure TDeque<T>.set_buf_size(const value: TSizeType);
begin
  if value > MAX_BUFFER_SIZE then
    raise EDSTLBufferSizeTooLargeException.Create('Buffer size should be less than ' +
                                                        inttostr(MAX_BUFFER_SIZE));
  Self.buf_size := value;
end;

procedure TDeque<T>.set_node(var it: TIterator<T>; node: TDequeMapNode<T>);
begin
  it.bnode := node;
  it.first := 0;
  it.last := buf_size div sizeOf(T) + 1;
end;

procedure TDeque<T>.create_map;
var
  node: TDequeMapNode<T>;
begin
  node := TDequeMapNode<T>.Create;
  node.buf := allocator.allocate(buf_size * sizeOf(T));
  set_node(fstart, node);
  set_node(ffinish, node);
  fstart.cur := fstart.first;
  ffinish.cur := fstart.first;
end;

function TDeque<T>.reserve_elements_at_front(n: integer): TIterator<T>;
var
  tmp: T;
  old_start: TIterator<T>;
begin
  old_start := fstart;
  tmp := front;
  while n > 0 do
  begin
    push_front(tmp);
    dec(n);
  end;
  Result := fstart;
  fstart := old_start;
end;

function TDeque<T>.reserve_elements_at_back(n: integer): TIterator<T>;
var
  tmp: T;
  old_finish: TIterator<T>;
begin
  old_finish := ffinish;
  tmp := back;
  while n > 0 do
  begin
    push_back(tmp);
    dec(n);
  end;
  Result := ffinish;
  ffinish := old_finish;
end;

procedure TDeque<T>.assign(first, last: TIterator<T>);
var
  iter: TIterator<T>;
begin
  (* clean up *)
  if not empty then clear;
  if fstart.bnode <> nil then
  begin
    allocator.deallocate(fstart.bnode.buf);
    fstart.bnode.Destroy;
  end;

  create_map;

  iter := first;
  while iter <> last do
  begin
    Self.push_back(iter);
    iter.handle.iadvance(iter);
  end;
end;

procedure TDeque<T>.assign(n: integer; u: T);
var
  i: integer;
begin
  (* clean up *)
  if not empty then clear;
  if fstart.bnode <> nil then
  begin
    allocator.deallocate(fstart.bnode.buf);
    fstart.bnode.Destroy;
  end;

  create_map;

  for i := 0 to n - 1 do
    Self.push_back(u);
end;

procedure TDeque<T>.add(const obj: T);
begin
  push_back(obj);
end;

procedure TDeque<T>.remove(const obj: T);
begin
end;

procedure TDeque<T>.clear;
var
  node: TDequeMapNode<T>;
begin
  node := fstart.bnode.next;
  if node <> nil then begin
    (* destroy all nodes between (fstart.bnode, ffinish.bnode) *)
    while (node <> ffinish.bnode) do
    begin
      allocator.deallocate(node.buf, buf_size * sizeOf(T));
      node := node.next;
      node.prev.Destroy;
    end;
  end;

  if fstart.bnode <> ffinish.bnode then allocator.deallocate(ffinish.bnode.buf,
                                                      buf_size * sizeOf(T));
  ffinish := fstart;
end;

function TDeque<T>.start: TIterator<T>;
begin
  result := fstart;
  result.flags := [ifBidirectional];
end;

function TDeque<T>.finish: TIterator<T>;
begin
  result := ffinish;
  result.flags := [ifBidirectional];
end;

function TDeque<T>.front: T;
begin
  if empty then
    exit;
  result := iget(fstart);
end;

function TDeque<T>.back: T;
begin
  if empty then
    exit;
  result := ffinish.bnode.buf[finish.cur - 1];
end;

function TDeque<T>.capacity: integer;
begin
  result := MaxInt;
end;

function TDeque<T>.max_size: integer;
begin
  result := TSizeType(-1);
end;

procedure TDeque<T>.reserve(const n: integer);
begin
end;

procedure TDeque<T>.resize(const n: integer);
begin
end;

procedure TDeque<T>.resize(const n: integer; const x: T);
var
  m: integer;
begin
  if size < n then
  begin
    m := n - size;
    while m > 0 do
    begin
      dec(m);
      push_back(x);
    end;
  end;
end;

function TDeque<T>.size: integer;
var
  i: integer;
  iter: TIterator<T>;
begin
  i := 0;
  iter := fstart;
  while iter <> ffinish do
  begin
    iadvance(iter);
    inc(i);
  end;
  result := i;
end;

function TDeque<T>.empty: boolean;
begin
  result := (fstart.bnode = ffinish.bnode) and (fstart.cur = ffinish.cur);
end;

function TDeque<T>.at(const idx: integer): T;
begin
  if idx > size then dstl_raise_exception(E_OUT_OF_BOUND);
  result := items[idx];
end;

function TDeque<T>.pop_front: T;
begin
  if fstart.cur = fstart.last - 1 then
  begin
    Result := fstart.bnode.buf[start.cur];
    inc(fstart.cur);
  end
  else Result := pop_front_aux;
end;

function TDeque<T>.pop_front_aux: T;
begin
  Result := fstart.bnode.buf[start.cur];
  set_node(fstart, fstart.bnode.next);
  allocator.deallocate(fstart.bnode.prev.buf, buf_size * sizeOf(T));
  fstart.bnode.prev.Destroy;
  fstart.cur := fstart.first;
end;

procedure TDeque<T>.push_front(const obj: T);
begin
  if fstart.cur <> fstart.first then
  (* we have enough space *)
  begin
    fstart.bnode.buf[start.cur - 1] := obj;
    fstart.cur := fstart.cur - 1;
  end
  else
    push_front_aux(obj);
end;

procedure TDeque<T>.push_front_aux(const obj: T);
begin
  (* create and allocate new node *)
  fstart.bnode.prev := TDequeMapNode<T>.Create;
  fstart.bnode.prev.next := fstart.bnode;
  fstart.bnode.prev.buf := allocator.allocate(buf_size * sizeOf(T));
  try
    (* set new node *)
    set_node(fstart, fstart.bnode.prev);
    fstart.cur := fstart.last - 1;
    fstart.bnode.buf[fstart.cur] := obj;
  except
    (* rollback *)
    set_node(fstart, fstart.bnode.next);
    fstart.cur := fstart.first;
    allocator.deallocate(fstart.bnode.prev.buf, buf_size * sizeOf(T));
    dstl_raise_exception(E_ALLOCATE);
  end;
end;

function TDeque<T>.pop_back: T;
begin
  if ffinish.cur <> ffinish.first then
  begin
    dec(ffinish.cur);
    Result := ffinish.bnode.buf[finish.cur];
  end
  else Result := pop_back_aux;
end;

function TDeque<T>.pop_back_aux: T;
begin
  set_node(ffinish, ffinish.bnode.prev);
  allocator.deallocate(ffinish.bnode.next.buf, buf_size * sizeOf(T));
  ffinish.bnode.next.Destroy;
  ffinish.bnode.next := nil;
  ffinish.cur := ffinish.last - 1;
  Result := ffinish.bnode.buf[finish.cur];
end;

procedure TDeque<T>.push_back(const obj: T);
begin
  if ffinish.cur <> ffinish.last - 1 then
  (* we have enough space *)
  begin
    ffinish.bnode.buf[finish.cur] := obj;
    inc(ffinish.cur);
  end
  else
    push_back_aux(obj);
end;

procedure TDeque<T>.push_back_aux(const obj: T);
begin
  (* create new node *)
  ffinish.bnode.next := TDequeMapNode<T>.Create;
  ffinish.bnode.next.prev := ffinish.bnode;
  (* set value *)
  ffinish.bnode.buf[finish.cur] := obj;
  (* set new node *)
  set_node(ffinish, ffinish.bnode.next);
  try
    (* allocate memory for the new node *)
    ffinish.bnode.buf := allocator.allocate(buf_size * sizeOf(T));
  except
    dstl_raise_exception(E_ALLOCATE);
  end;
  (* reset ffinish.cur *)
  ffinish.cur := ffinish.first;
end;

function TDeque<T>.insert(Iterator: TIterator<T>; const obj: T): TIterator<T>;
begin
  (* insert to the head *)
  if iequals(fstart, Iterator) then
  begin
    push_front(obj);
    Result := fstart;
  end
  (* insert to the tail *)
  else if iequals(ffinish, Iterator) then
  begin
    push_back(obj);
    Result := ffinish;
    iretreat(Result);
  end
  else Result := insert_aux(Iterator, obj);
end;

function TDeque<T>.insert_aux(Iterator: TIterator<T>; const obj: T): TIterator<T>;
var
  index: integer;
  front1, front2, pos1, back1, back2: TIterator<T>;
begin
  index := idistance(fstart, Iterator);
  if (index < size div 2) then
  begin
    push_front(front);
    front1 := fstart; iadvance(front1);
    front2 := front1; iadvance(front2);
    pos1 := Iterator; iadvance(pos1);
    TIterAlgorithms<T>.copy(front2, pos1, front1);
  end
  else begin
    push_back(back);
    back1 := ffinish; iretreat(back1);
    back2 := back1; iretreat(back2);
    TIterAlgorithms<T>.copy_backward(Iterator, back2, back1);
  end;
  iput(Iterator, obj);
  Result := Iterator;
end;

procedure TDeque<T>.insert(position: TIterator<T>; n: integer; const obj: T);
begin
  fill_insert(position, n, obj);
end;

procedure TDeque<T>.fill_insert(position: TIterator<T>; n: integer; const obj: T);
var
  new_start, new_finish: TIterator<T>;
begin
  if position.cur = fstart.cur then
  begin
    new_start := reserve_elements_at_front(n);
    try
      TIterAlgorithms<T>.fill(new_start, fstart, obj);
      fstart := new_start;
    except
    end;
  end
  else if position.cur = ffinish.cur then
  begin
    new_finish := reserve_elements_at_back(n);
    try
      TIterAlgorithms<T>.fill(ffinish, new_finish, obj);
      ffinish := ffinish;
    except
    end;
  end
  else
    insert_aux(position, n, obj);
end;

procedure TDeque<T>.insert_aux(position: TIterator<T>; n: integer; const obj: T);
var
  elemsbef, elemsaft, leng: integer;
  new_start, old_start, fstart_n, tmp, mid2: TIterator<T>;
  new_finish, old_finish, ffinish_n: TIterator<T>;
begin
  elemsbef := idistance(fstart, position);
  leng := size;

  if elemsbef < leng div 2 then
  begin
    new_start := reserve_elements_at_front(n);
    old_start := fstart;
    try
      if elemsbef >= n then
      begin
        fstart_n := fstart;
        iadvance_by(fstart_n, n);
        TIterAlgorithms<T>.copy(fstart, fstart_n, new_start);
        fstart := new_start;
        TIterAlgorithms<T>.copy(fstart_n, position, old_start);
        tmp := position;
        iretreat_by(tmp, n);
        TIterAlgorithms<T>.fill(tmp, position, obj);
      end
      else begin
        mid2 := TIterAlgorithms<T>.copy(fstart, position, new_start);
        TIterAlgorithms<T>.fill(mid2, fstart, obj);
        fstart := new_start;
        TIterAlgorithms<T>.fill(old_start, position, obj);
      end
    except
    end;
  end
  else begin
    new_finish := reserve_elements_at_back(n);
    old_finish := ffinish;
    elemsaft := leng - elemsbef;
    try
      if elemsaft > n then
      begin
        ffinish_n := ffinish;
        iretreat_by(ffinish_n, n);
        TIterAlgorithms<T>.copy(ffinish_n, ffinish, ffinish);
        ffinish := new_finish;
        TIterAlgorithms<T>.copy_backward(position, ffinish_n, old_finish);
        tmp := position;
        iadvance_by(tmp, n);
        TIterAlgorithms<T>.fill(position, tmp, obj);
      end
      else begin
        tmp := position;
        iadvance_by(tmp, n);
        TIterAlgorithms<T>.fill(ffinish, tmp, obj);
        TIterAlgorithms<T>.copy(position, ffinish, tmp);
        ffinish := new_finish;
        TIterAlgorithms<T>.fill(position, old_finish, obj);
      end;
    except
    end;
  end;
end;

procedure TDeque<T>.insert(position: TIterator<T>; first, last: TIterator<T>);
var
  n: integer;
  new_start, new_finish: TIterator<T>;
begin
  n := first.handle.idistance(first, last);

  (* insert to head *)
  if  position.cur = fstart.cur then
  begin
    new_start := reserve_elements_at_front(n);
    TIterAlgorithms<T>.copy(first, last, new_start);
    fstart := new_start;
  end
  (* insert to tail *)
  else if position.cur = ffinish.cur then
  begin
    new_finish := reserve_elements_at_back(n);
    TIterAlgorithms<T>.copy(first, last, ffinish);
    ffinish := new_finish;
  end
  else insert_aux(position, first, last, n);
end;

procedure TDeque<T>.insert_aux(position: TIterator<T>; first, last: TIterator<T>; n: integer);
var
  elemsbef, elemsaft: integer;
  leng, tmp: integer;
  old_start, new_start, fstart_n, mid, mid2: TIterator<T>;
  old_finish, new_finish, ffinish_n: TIterator<T>;
begin
  elemsbef := idistance(fstart, position);
  leng := size;
  if elemsbef < leng div 2 then
  begin
    new_start := reserve_elements_at_front(n);
    old_start := fstart;
    try
      if elemsbef >= n then
      begin
        fstart_n := fstart;
        iadvance_by(fstart_n, n);
        TIterAlgorithms<T>.copy(fstart, fstart_n, new_start);
        fstart := new_start;
        TIterAlgorithms<T>.copy(fstart_n, position, old_start);
        iretreat_by(position, n);
        TIterAlgorithms<T>.copy(first, last, position);
      end
      else begin
        mid := first;
        tmp := n - elemsbef;
        while tmp > 0 do
        begin
          mid.handle.iadvance(mid);
          dec(tmp);
        end;
        mid2 := TIterAlgorithms<T>.copy(fstart, position, new_start);
        TIterAlgorithms<T>.copy(first, mid, mid2);
        fstart := new_start;
        TIterAlgorithms<T>.copy(mid, last, old_start);
      end;
    except
    end;  (* try *)
  end
  else begin
    new_finish := reserve_elements_at_back(n);
    old_finish := ffinish;
    elemsaft := leng - elemsbef;

    try
      if elemsaft > n then
      begin
        ffinish_n := ffinish;
        iretreat_by(ffinish_n, n);
        TIterAlgorithms<T>.copy(ffinish_n, ffinish, ffinish);
        ffinish := new_finish;
        TIterAlgorithms<T>.copy_backward(position, ffinish_n, old_finish);
        TIterAlgorithms<T>.copy(first, last, position);
      end
      else begin
        mid := first;
        tmp := elemsaft;
        while tmp > 0 do
        begin
          mid.handle.iadvance(mid);
          dec(tmp);
        end;
        mid2 := TIterAlgorithms<T>.copy(mid, last, ffinish);
        TIterAlgorithms<T>.copy(position, ffinish, mid2);
        ffinish := new_finish;
        TIterAlgorithms<T>.copy(first, mid, position);
      end;
    except
    end;
  end;
end;

function TDeque<T>.erase(it: TIterator<T>): TIterator<T>;
var
  next: TIterator<T>;
  index: integer;
begin
  next := it;
  iadvance(next);
  index := idistance(fstart, it);

  (* move elements *)
  if (index < size div 2) then
  begin
    TIterAlgorithms<T>.copy_backward(fstart, it, next);
    pop_front;
  end
  else
  begin
    TIterAlgorithms<T>.copy(next, ffinish, it);
    pop_back;
  end;

  Result := fstart;
  while index > 0 do
  begin
    iadvance(Result);
    dec(index);
  end;
end;

function TDeque<T>.erase(_start, _finish: TIterator<T>): TIterator<T>;
var
  n: integer;
  elems_before: integer;
  new_start, new_finish: TIterator<T>;
  cur: TDequeMapNode<T>;
begin
  (* if _start == fstart and _finish == ffinish just clear *)
  if (iequals(fstart, _start)) and (iequals(_finish, ffinish)) then
  begin
    clear;
    Result := ffinish;
  end
  else begin
    n := idistance(_start, _finish);
    elems_before := idistance(fstart, _start);

    if elems_before < (size - n) div 2 then
    begin
      (* move elements *)
      TIterAlgorithms<T>.copy_backward(fstart, _start, _finish);
      new_start := fstart;
      iadvance_by(new_start, n);
      cur := fstart.bnode;
      (* free buffer *)
      while cur <> new_start.bnode do
      begin
        allocator.deallocate(cur.buf, buf_size * sizeOf(T));
        cur := cur.next;
      end;
      (* set new fstart *)
      fstart := new_start;
    end
    else begin
      (* move elements *)
      TIterAlgorithms<T>.copy(_finish, ffinish, _start);
      new_finish := ffinish;
      iretreat_by(new_finish, n);
      (* free buffer *)
      cur := new_finish.bnode;
      cur := cur.next;
      allocator.deallocate(cur.buf, buf_size * sizeOf(T));
      while cur <> ffinish.bnode do
      begin
        cur := cur.next;
        allocator.deallocate(cur.buf, buf_size * sizeOf(T));
      end;
      ffinish := new_finish;
    end;
    Result := fstart;
    iadvance_by(Result, elems_before);
  end;
end;

procedure TDeque<T>.swap(var dqe: TDeque<T>);
begin
  (* swap allocator, buf_size, map, fstart and ffinish *)
  _TSwap<IAllocator<T>>.swap(Self.allocator, dqe.allocator);
  _TSwap<integer>.swap(Self.buf_size, dqe.buf_size);
  _TSwap<TDequeMapNode<T>>.swap(Self.map, dqe.map);
  _TSwap<TIterator<T>>.swap(Self.fstart, dqe.fstart);
  _TSwap<TIterator<T>>.swap(Self.ffinish, dqe.ffinish);
end;

function TDeque<T>.get_allocator: IAllocator<T>;
begin
  Result := Self.allocator;
end;

end.
