{$L LMATH32.OBJ}

program Test32bit;

type
  Int32  = LongInt;
  UInt32 = LongInt;

function s32add(A, B: Int32): Int32; far; external;
function u32add(A, B: UInt32): UInt32; far; external;
function s32sub(A, B: Int32): Int32; far; external;
function u32sub(A, B: UInt32): UInt32; far; external;
function s32neg(A: Int32): Int32; far; external;
function s32mul(A, B: Int32): Int32; far; external;
function u32mul(A, B: UInt32): UInt32; far; external;
function s32div(A, B: Int32): Int32; far; external;
function u32div(A, B: UInt32): UInt32; far; external;
function s32mod(A, B: Int32): Int32; far; external;
function u32mod(A, B: UInt32): UInt32; far; external;
function s32shl(Val: Int32; Count: Integer): Int32; far; external;
function u32shl(Val: UInt32; Count: Integer): UInt32; far; external;
function s32shr(Val: Int32; Count: Integer): Int32; far; external;
function u32shr(Val: UInt32; Count: Integer): UInt32; far; external;
function s32cmp(A, B: Int32): Integer; far; external;
function u32cmp(A, B: UInt32): Integer; far; external;
procedure s32toa(Val: Int32; Buffer: PChar); far; external;
procedure u32toa(Val: UInt32; Buffer: PChar); far; external;

procedure WriteHexLong(L: LongInt);
const
  HexDigits: array[0..15] of Char = '0123456789ABCDEF';
begin
  Write(HexDigits[L shr 28 and $F]);
  Write(HexDigits[L shr 24 and $F]);
  Write(HexDigits[L shr 20 and $F]);
  Write(HexDigits[L shr 16 and $F]);
  Write(HexDigits[L shr 12 and $F]);
  Write(HexDigits[L shr 8 and $F]);
  Write(HexDigits[L shr 4 and $F]);
  Write(HexDigits[L and $F]);
end;

procedure TestCase(TestName: String; Expected, Actual: LongInt; OK: Boolean);
begin
  Write(TestName:30, ' : ');
  if OK then
    Writeln('PASS')
  else
  begin
    Write('FAIL - Expected 0x');
    WriteHexLong(Expected);
    Write(' got 0x');
    WriteHexLong(Actual);
    Writeln;
  end;
end;

procedure TestAdd;
begin
  Writeln('--- Addition ---');
  TestCase('u32add 0+0', u32add(0,0), 0, u32add(0,0)=0);
  TestCase('s32add 0+0', s32add(0,0), 0, s32add(0,0)=0);
  TestCase('u32add 1+1', u32add(1,1), 2, u32add(1,1)=2);
  TestCase('s32add 1+1', s32add(1,1), 2, s32add(1,1)=2);
  TestCase('u32add max+1', u32add($FFFFFFFF,1), 0, u32add($FFFFFFFF,1)=0);
  TestCase('s32add -1 + -1', s32add(-1,-1), -2, s32add(-1,-1)=-2);
  TestCase('s32add -2^31 + -1', s32add($80000000,-1), $7FFFFFFF, s32add($80000000,-1)=$7FFFFFFF);
  TestCase('s32add -2^31+1 + 2^31-1', s32add($80000001,$7FFFFFFF), 0, s32add($80000001,$7FFFFFFF)=0);
end;

procedure TestSub;
begin
  Writeln('--- Subtraction ---');
  TestCase('u32sub 5-3', u32sub(5,3), 2, u32sub(5,3)=2);
  TestCase('s32sub 5-3', s32sub(5,3), 2, s32sub(5,3)=2);
  TestCase('s32sub 3-5', s32sub(3,5), -2, s32sub(3,5)=-2);
  TestCase('s32sub -2^31 - 1', s32sub($80000000,1), $7FFFFFFF, s32sub($80000000,1)=$7FFFFFFF);
  TestCase('u32sub 0-1', u32sub(0,1), $FFFFFFFF, u32sub(0,1)=$FFFFFFFF);
  TestCase('s32sub -1 - (-1)', s32sub(-1,-1), 0, s32sub(-1,-1)=0);
end;

procedure TestNeg;
begin
  Writeln('--- Negation ---');
  TestCase('s32neg 0', s32neg(0), 0, s32neg(0)=0);
  TestCase('s32neg 1', s32neg(1), -1, s32neg(1)=-1);
  TestCase('s32neg -1', s32neg(-1), 1, s32neg(-1)=1);
  TestCase('s32neg -2^31', s32neg($80000000), $80000000, s32neg($80000000)=$80000000);  { overflow }
  TestCase('s32neg 2^31-1', s32neg($7FFFFFFF), $80000001, s32neg($7FFFFFFF)=$80000001);
end;

procedure TestMul;
begin
  Writeln('--- Multiplication ---');
  TestCase('u32mul 2*3', u32mul(2,3), 6, u32mul(2,3)=6);
  TestCase('s32mul 2*3', s32mul(2,3), 6, s32mul(2,3)=6);
  TestCase('u32mul max*max', u32mul($FFFFFFFF,$FFFFFFFF), 1, u32mul($FFFFFFFF,$FFFFFFFF)=1);
  TestCase('s32mul -1 * -1', s32mul(-1,-1), 1, s32mul(-1,-1)=1);
  TestCase('s32mul 2 * -2', s32mul(2,-2), -4, s32mul(2,-2)=-4);
  TestCase('s32mul -2^31 * -1', s32mul($80000000,-1), $80000000, s32mul($80000000,-1)=$80000000); { overflow }
  TestCase('u32mul 2^31 * 2', u32mul($80000000,2), 0, u32mul($80000000,2)=0);
end;

procedure TestDivMod;
begin
  Writeln('--- Division/Modulo ---');
  TestCase('u32div 10/3', u32div(10,3), 3, u32div(10,3)=3);
  TestCase('u32mod 10%3', u32mod(10,3), 1, u32mod(10,3)=1);
  TestCase('s32div 10/3', s32div(10,3), 3, s32div(10,3)=3);
  TestCase('s32mod 10%3', s32mod(10,3), 1, s32mod(10,3)=1);
  TestCase('s32div 10 / -3', s32div(10,-3), -3, s32div(10,-3)=-3);
  TestCase('s32mod 10 % -3', s32mod(10,-3), 1, s32mod(10,-3)=1);
  TestCase('s32div -10 / 3', s32div(-10,3), -3, s32div(-10,3)=-3);
  TestCase('s32mod -10 % 3', s32mod(-10,3), -1, s32mod(-10,3)=-1);
  TestCase('s32div -10 / -3', s32div(-10,-3), 3, s32div(-10,-3)=3);
  TestCase('s32mod -10 % -3', s32mod(-10,-3), -1, s32mod(-10,-3)=-1);
  TestCase('u32div max/1', u32div($FFFFFFFF,1), $FFFFFFFF, u32div($FFFFFFFF,1)=$FFFFFFFF);
  TestCase('u32mod max%1', u32mod($FFFFFFFF,1), 0, u32mod($FFFFFFFF,1)=0);
  TestCase('s32div -2^31 / 2', s32div($80000000,2), $C0000000, s32div($80000000,2)=$C0000000);
  TestCase('s32mod -2^31 % 2', s32mod($80000000,2), 0, s32mod($80000000,2)=0);
  TestCase('s32div -2^31 / -1', s32div($80000000,-1), $80000000, s32div($80000000,-1)=$80000000);
  TestCase('s32mod -2^31 % -1', s32mod($80000000,-1), 0, s32mod($80000000,-1)=0);
  TestCase('u32div 1/0', u32div(1,0), $FFFFFFFF, u32div(1,0)=$FFFFFFFF);
  TestCase('s32div 1/0', s32div(1,0), -1, s32div(1,0)=-1);
end;

procedure TestShift;
begin
  Writeln('--- Shifts ---');
  TestCase('u32shl 1<<1', u32shl(1,1), 2, u32shl(1,1)=2);
  TestCase('s32shl 1<<1', s32shl(1,1), 2, s32shl(1,1)=2);
  TestCase('u32shl 1<<31', u32shl(1,31), $80000000, u32shl(1,31)=$80000000);
  TestCase('s32shl 1<<31', s32shl(1,31), $80000000, s32shl(1,31)=$80000000);
  TestCase('u32shr 0x8000>>1', u32shr($8000,1), $4000, u32shr($8000,1)=$4000);
  TestCase('s32shr 0x8000>>1', s32shr($8000,1), $4000, s32shr($8000,1)=$4000);
  TestCase('u32shr 0x80000000>>1', u32shr($80000000,1), $40000000, u32shr($80000000,1)=$40000000);
  TestCase('s32shr -2^31>>1', s32shr($80000000,1), $C0000000, s32shr($80000000,1)=$C0000000);
  TestCase('s32shr -1>>10', s32shr(-1,10), -1, s32shr(-1,10)=-1);
  TestCase('u32shr max>>16', u32shr($FFFFFFFF,16), $FFFF, u32shr($FFFFFFFF,16)=$FFFF);
  TestCase('u32shl max<<0', u32shl($FFFFFFFF,0), $FFFFFFFF, u32shl($FFFFFFFF,0)=$FFFFFFFF);
end;

procedure TestCmp;
begin
  Writeln('--- Comparison ---');
  Writeln('u32cmp 0,0 : ', u32cmp(0,0), ' expected 0');
  Writeln('s32cmp 0,0 : ', s32cmp(0,0), ' expected 0');
  Writeln('u32cmp 1,0 : ', u32cmp(1,0), ' expected 1');
  Writeln('s32cmp 1,0 : ', s32cmp(1,0), ' expected 1');
  Writeln('u32cmp max,0 : ', u32cmp($FFFFFFFF,0), ' expected 1');
  Writeln('s32cmp -1,0 : ', s32cmp(-1,0), ' expected -1');
  Writeln('u32cmp 2^31,0 : ', u32cmp($80000000,0), ' expected 1');
  Writeln('s32cmp -2^31,0 : ', s32cmp($80000000,0), ' expected -1');
  Writeln('s32cmp -2^31, 2^31-1 : ', s32cmp($80000000,$7FFFFFFF), ' expected -1');
  Writeln('u32cmp 2^31, 2^31-1 : ', u32cmp($80000000,$7FFFFFFF), ' expected 1');
  Writeln('s32cmp -2^31+1, -2^31 : ', s32cmp($80000001,$80000000), ' expected 1');
end;

procedure TestToA;
var
  Buf: array[0..15] of Char;
begin
  Writeln('--- String conversion ---');
  u32toa(0, Buf); Writeln('u32toa 0 : "', Buf, '" expected "0"');
  s32toa(0, Buf); Writeln('s32toa 0 : "', Buf, '" expected "0"');
  u32toa(1, Buf); Writeln('u32toa 1 : "', Buf, '" expected "1"');
  s32toa(1, Buf); Writeln('s32toa 1 : "', Buf, '" expected "1"');
  u32toa($FFFFFFFF, Buf); Writeln('u32toa max : "', Buf, '" expected "4294967295"');
  s32toa(-1, Buf); Writeln('s32toa -1 : "', Buf, '" expected "-1"');
  s32toa($80000000, Buf); Writeln('s32toa -2^31 : "', Buf, '" expected "-2147483648"');
  u32toa($80000000, Buf); Writeln('u32toa 2^31 : "', Buf, '" expected "2147483648"');
  s32toa($7FFFFFFF, Buf); Writeln('s32toa 2^31-1 : "', Buf, '" expected "2147483647"');
  u32toa($7FFFFFFF, Buf); Writeln('u32toa 2^31-1 : "', Buf, '" expected "2147483647"');
end;

begin
  Writeln('32-bit Arithmetic Test Suite');
  Writeln('=============================');
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

