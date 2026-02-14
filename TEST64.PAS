{  MIT License

Copyright (c) 2026 Viacheslav Komenda

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. }
{$A-,I-,S-,R-,D-,L-,Q-,F-,G-,O-,B-}
program Test64;

{$L LMATH64.OBJ}

type
  TWord4 = array[0..3] of Word;

procedure s64add(var Res, A, B: TWord4); far; external;
procedure u64add(var Res, A, B: TWord4); far; external;
procedure s64sub(var Res, A, B: TWord4); far; external;
procedure u64sub(var Res, A, B: TWord4); far; external;
procedure s64neg(var Res, A: TWord4); far; external;
procedure s64mul(var Res, A, B: TWord4); far; external;
procedure u64mul(var Res, A, B: TWord4); far; external;
procedure s64div(var Res, A, B: TWord4); far; external;
procedure u64div(var Res, A, B: TWord4); far; external;
procedure s64mod(var Res, A, B: TWord4); far; external;
procedure u64mod(var Res, A, B: TWord4); far; external;
procedure s64shl(var Res, Val: TWord4; Count: Word); far; external;
procedure u64shl(var Res, Val: TWord4; Count: Word); far; external;
procedure s64shr(var Res, Val: TWord4; Count: Word); far; external;
procedure u64shr(var Res, Val: TWord4; Count: Word); far; external;
function s64cmp(var A, B: TWord4): Integer; far; external;
function u64cmp(var A, B: TWord4): Integer; far; external;
procedure s64toa(var Val: TWord4; Buffer: PChar); far; external;
procedure u64toa(var Val: TWord4; Buffer: PChar); far; external;

procedure SetWord4(var X: TWord4; a3, a2, a1, a0: Word);
begin
  X[0] := a0;
  X[1] := a1;
  X[2] := a2;
  X[3] := a3;
end;

function Equal(const A, B: TWord4): Boolean;
var i: Integer;
begin
  Equal := True;
  for i := 0 to 3 do
    if A[i] <> B[i] then
    begin
      Equal := False;
      Exit;
    end;
end;

procedure WriteHexWord(w: Word);
const
  HexDigits: array[0..15] of Char = '0123456789ABCDEF';
begin
  Write(HexDigits[w shr 12 and $F]);
  Write(HexDigits[w shr 8 and $F]);
  Write(HexDigits[w shr 4 and $F]);
  Write(HexDigits[w and $F]);
end;

procedure PrintHex(const X: TWord4);
begin
  WriteHexWord(X[3]);
  WriteHexWord(X[2]);
  WriteHexWord(X[1]);
  WriteHexWord(X[0]);
end;

procedure TestCase(TestName: String; Expected, Actual: TWord4; OK: Boolean);
begin
  Write(TestName:30, ' : ');
  if OK then
    Writeln('PASS')
  else
  begin
    Write('FAIL - Expected ');
    PrintHex(Expected);
    Write(' got ');
    PrintHex(Actual);
    Writeln;
  end;
end;

procedure TestAdd;
var A, B, Res, Exp: TWord4;
begin
  Writeln('--- Addition ---');
  SetWord4(A, 0,0,0,0); SetWord4(B, 0,0,0,0); SetWord4(Exp, 0,0,0,0);
  u64add(Res, A, B); TestCase('U64ADD 0+0', Exp, Res, Equal(Res, Exp));
  s64add(Res, A, B); TestCase('S64ADD 0+0', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,1); SetWord4(B, 0,0,0,1); SetWord4(Exp, 0,0,0,2);
  u64add(Res, A, B); TestCase('U64ADD 1+1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF); SetWord4(B, 0,0,0,1); SetWord4(Exp, 0,0,0,0);
  u64add(Res, A, B); TestCase('U64ADD max+1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,1);
  SetWord4(B, $7FFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, 0,0,0,0);
  s64add(Res, A, B); TestCase('S64ADD (-2^63+1) + (2^63-1)', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $7FFF,$FFFF,$FFFF,$FFFF);
  s64add(Res, A, B); TestCase('S64ADD -2^63 + -1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFE);
  s64add(Res, A, B); TestCase('S64ADD -1 + -1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $7FFF,$FFFF,$FFFF,$FFFF);
  SetWord4(B, $7FFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFE);
  u64add(Res, A, B); TestCase('U64ADD (2^63-1)+(2^63-1)', Exp, Res, Equal(Res, Exp));
end;

procedure TestSub;
var A, B, Res, Exp: TWord4;
begin
  Writeln('--- Subtraction ---');
  SetWord4(A, 0,0,0,5); SetWord4(B, 0,0,0,3); SetWord4(Exp, 0,0,0,2);
  u64sub(Res, A, B); TestCase('U64SUB 5-3', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,3); SetWord4(B, 0,0,0,5); SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFE);
  s64sub(Res, A, B); TestCase('S64SUB 3-5', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(B, 0,0,0,1);
  SetWord4(Exp, $7FFF,$FFFF,$FFFF,$FFFF);
  s64sub(Res, A, B); TestCase('S64SUB -2^63 - 1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, 0,0,0,0);
  s64sub(Res, A, B); TestCase('S64SUB (-1)-(-1)', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $7FFF,$FFFF,$FFFF,$FFFF);
  SetWord4(B, $8000,0,0,0);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  s64sub(Res, A, B); TestCase('S64SUB (2^63-1) - (-2^63)', Exp, Res, Equal(Res, Exp));
end;

procedure TestNeg;
var A, Res, Exp: TWord4;
begin
  Writeln('--- Negation ---');
  SetWord4(A, 0,0,0,0); SetWord4(Exp, 0,0,0,0);
  s64neg(Res, A); TestCase('S64NEG 0', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,1); SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  s64neg(Res, A); TestCase('S64NEG 1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF); SetWord4(Exp, 0,0,0,1);
  s64neg(Res, A); TestCase('S64NEG -1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0); SetWord4(Exp, $8000,0,0,0);
  s64neg(Res, A); TestCase('S64NEG -2^63', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $7FFF,$FFFF,$FFFF,$FFFF); SetWord4(Exp, $8000,0,0,1);
  s64neg(Res, A); TestCase('S64NEG 2^63-1', Exp, Res, Equal(Res, Exp));
end;

procedure TestMul;
var A, B, Res, Exp: TWord4;
begin
  Writeln('--- Multiplication ---');
  SetWord4(A, 0,0,0,2); SetWord4(B, 0,0,0,3); SetWord4(Exp, 0,0,0,6);
  u64mul(Res, A, B); TestCase('U64MUL 2*3', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF); SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, 0,0,0,1);
  u64mul(Res, A, B); TestCase('U64MUL max*max', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, 0,0,0,1);
  s64mul(Res, A, B); TestCase('S64MUL -1 * -1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,2);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFE);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFC);
  s64mul(Res, A, B); TestCase('S64MUL 2 * -2', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $8000,0,0,0);
  s64mul(Res, A, B); TestCase('S64MUL -2^63 * -1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $7FFF,$FFFF,$FFFF,$FFFF);
  SetWord4(B, 0,0,0,2);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFE);
  u64mul(Res, A, B); TestCase('U64MUL (2^63-1)*2', Exp, Res, Equal(Res, Exp));
end;

procedure TestDivMod;
var A, B, Res, Exp: TWord4;
begin
  Writeln('--- Division/Modulo ---');

  SetWord4(A, 0,0,0,10); SetWord4(B, 0,0,0,3);
  SetWord4(Exp, 0,0,0,3);
  u64div(Res, A, B); TestCase('U64DIV 10/3', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, 0,0,0,1);
  u64mod(Res, A, B); TestCase('U64MOD 10%3', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF); SetWord4(B, 0,0,0,1);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  u64div(Res, A, B); TestCase('U64DIV max/1', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, 0,0,0,0);
  u64mod(Res, A, B); TestCase('U64MOD max%1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,10);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFD);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFD);
  s64div(Res, A, B); TestCase('S64DIV 10 / -3', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, 0,0,0,1);
  s64mod(Res, A, B); TestCase('S64MOD 10 % -3', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFF6);
  SetWord4(B, 0,0,0,3);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFD);
  s64div(Res, A, B); TestCase('S64DIV -10 / 3', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  s64mod(Res, A, B); TestCase('S64MOD -10 % 3', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFF6);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFD);
  SetWord4(Exp, 0,0,0,3);
  s64div(Res, A, B); TestCase('S64DIV -10 / -3', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  s64mod(Res, A, B); TestCase('S64MOD -10 % -3', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(B, 0,0,0,2);
  SetWord4(Exp, $C000,0,0,0);
  s64div(Res, A, B); TestCase('S64DIV -2^63 / 2', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, 0,0,0,0);
  s64mod(Res, A, B); TestCase('S64MOD -2^63 % 2', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(B, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $8000,0,0,0);
  s64div(Res, A, B); TestCase('S64DIV -2^63 / -1', Exp, Res, Equal(Res, Exp));
  SetWord4(Exp, 0,0,0,0);
  s64mod(Res, A, B); TestCase('S64MOD -2^63 % -1', Exp, Res, Equal(Res, Exp));
end;

procedure TestShift;
var A, Res, Exp: TWord4;
begin
  Writeln('--- Shifts ---');
  SetWord4(A, 0,0,0,1);
  SetWord4(Exp, 0,0,0,2);
  u64shl(Res, A, 1); TestCase('U64SHL 1<<1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,1);
  SetWord4(Exp, 0,0,0,$8000);
  u64shl(Res, A, 15); TestCase('U64SHL 1<<15', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,1);
  SetWord4(Exp, 0,0,1,0);
  u64shl(Res, A, 16); TestCase('U64SHL 1<<16', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(Exp, $C000,0,0,0);
  s64shr(Res, A, 1); TestCase('S64SHR -2^63 >> 1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, 0,0,0,$8000);
  SetWord4(Exp, 0,0,0,$4000);
  u64shr(Res, A, 1); TestCase('U64SHR 0x8000>>1', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $8000,0,0,0);
  SetWord4(Exp, $E000,0,0,0);
  s64shr(Res, A, 2); TestCase('S64SHR -2^63 >> 2', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  s64shr(Res, A, 10); TestCase('S64SHR -1 >> 10', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, 0,0,$FFFF,$FFFF);
  u64shr(Res, A, 32); TestCase('U64SHR max >> 32', Exp, Res, Equal(Res, Exp));

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF);
  SetWord4(Exp, $FFFF,$FFFF,$FFFF,$FFFF);
  u64shl(Res, A, 0); TestCase('U64SHL max << 0', Exp, Res, Equal(Res, Exp));
end;

procedure TestCmp;
var A, B: TWord4;
    r: Integer;
begin
  Writeln('--- Comparison ---');
  SetWord4(A, 0,0,0,0); SetWord4(B, 0,0,0,0);
  r := u64cmp(A,B); Writeln('U64CMP 0,0 : ', r, ' expected 0');
  r := s64cmp(A,B); Writeln('S64CMP 0,0 : ', r, ' expected 0');

  SetWord4(A, 0,0,0,1); SetWord4(B, 0,0,0,0);
  r := u64cmp(A,B); Writeln('U64CMP 1,0 : ', r, ' expected 1');
  r := s64cmp(A,B); Writeln('S64CMP 1,0 : ', r, ' expected 1');

  SetWord4(A, $FFFF,$FFFF,$FFFF,$FFFF); SetWord4(B, 0,0,0,0);
  r := u64cmp(A,B); Writeln('U64CMP max,0 : ', r, ' expected 1');
  r := s64cmp(A,B); Writeln('S64CMP -1,0 : ', r, ' expected -1');

  SetWord4(A, $8000,0,0,0); SetWord4(B, 0,0,0,0);
  r := u64cmp(A,B); Writeln('U64CMP 2^63,0 : ', r, ' expected 1');
  r := s64cmp(A,B); Writeln('S64CMP -2^63,0 : ', r, ' expected -1');

  SetWord4(A, $8000,0,0,0); SetWord4(B, $7FFF,$FFFF,$FFFF,$FFFF);
  r := s64cmp(A,B); Writeln('S64CMP -2^63, 2^63-1 : ', r, ' expected -1');
  r := u64cmp(A,B); Writeln('U64CMP 2^63, 2^63-1 : ', r, ' expected 1');

  SetWord4(A, $8000,0,0,1); SetWord4(B, $8000,0,0,0);
  r := s64cmp(A,B); Writeln('S64CMP -2^63+1, -2^63 : ', r, ' expected 1');
end;

procedure TestToA;
var Val: TWord4;
    Buf: array[0..31] of Char;
begin
  Writeln('--- String conversion ---');
  SetWord4(Val, 0,0,0,0);
  u64toa(Val, Buf); Writeln('U64TOA 0 : "', Buf, '" expected "0"');
  s64toa(Val, Buf); Writeln('S64TOA 0 : "', Buf, '" expected "0"');

  SetWord4(Val, 0,0,0,1);
  u64toa(Val, Buf); Writeln('U64TOA 1 : "', Buf, '" expected "1"');

  SetWord4(Val, $FFFF,$FFFF,$FFFF,$FFFF);
  u64toa(Val, Buf); Writeln('U64TOA max : "', Buf, '" expected "18446744073709551615"');

  SetWord4(Val, $FFFF,$FFFF,$FFFF,$FFFF);
  s64toa(Val, Buf); Writeln('S64TOA -1 : "', Buf, '" expected "-1"');

  SetWord4(Val, $8000,0,0,0);
  s64toa(Val, Buf); Writeln('S64TOA -2^63 : "', Buf, '" expected "-9223372036854775808"');

  SetWord4(Val, $8000,0,0,0);
  u64toa(Val, Buf); Writeln('U64TOA 2^63 : "', Buf, '" expected "9223372036854775808"');

  SetWord4(Val, $7FFF,$FFFF,$FFFF,$FFFF);
  u64toa(Val, Buf); Writeln('U64TOA 2^63-1 : "', Buf, '" expected "9223372036854775807"');
  s64toa(Val, Buf); Writeln('S64TOA 2^63-1 : "', Buf, '" expected "9223372036854775807"');

  SetWord4(Val, $FFFF,$FFFF,$FFFF,$FFFF);
  s64toa(Val, Buf); Writeln('S64TOA -1 again : "', Buf, '" expected "-1"');
end;

begin
  Writeln('64-bit Arithmetic Test Suite (Corrected)');
  Writeln('=========================================');
  TestAdd;
  TestSub;
  TestNeg;
  TestMul;
  TestDivMod;
  TestShift;
  TestCmp;
  TestToA;
  Writeln('Testing complete.');
end.

