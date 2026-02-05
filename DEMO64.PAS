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
Program Demo64;

{ =========================================================================== }
{  DEMO 64: BALLISTIC PHYSICS SIMULATOR (High Precision)                      }
{  Format: 48.16 Fixed-Point (48-bit Integer, 16-bit Fraction).               }
{  Uses LMath32 unit.                                                         }
{ =========================================================================== }

Uses LMath32;

Const
  SHIFT_BITS = 16; { 16-bit fractional part }
  
Type
  TFixed = Int64;

Var
  { Simulation State }
  PosX, PosY   : TFixed;
  VelX, VelY   : TFixed;
  
  { Physics Constants }
  Gravity      : TFixed;
  Wind         : TFixed;
  Friction     : TFixed;
  Bounce       : TFixed;
  OneFixed     : TFixed;
  
  { Limits & Helpers }
  Zero64       : TFixed;
  Limit50      : TFixed;
  LimitNeg50   : TFixed;
  Limit150     : TFixed;
  Limit10      : TFixed;
  
  Scale10k     : TFixed; { For printing 4 decimal places }
  Const204     : TFixed; { Ground friction factor }

  TimeStep     : Integer;
  TotalDist    : UInt64;
  LastX, LastY : TFixed;
  TempDist     : UInt64;
  
  StrBuf       : Array[0..31] of Char;

{ =========================================================================== }
{  Helper routines                                                            }
{ =========================================================================== }

{ Conversion: Integer -> Fixed (Res := I << 16) }
Procedure IntToFixed(Var Res: TFixed; I: Integer);
Var
  Temp: TFixed;
Begin
  if I < 0 then
    MakeInt64(Temp, -1, I)
  else
    MakeInt64(Temp, 0, I);
    
  s64shl(Res, Temp, SHIFT_BITS);
End;

{ Output Fixed Point with 4 decimal places precision }
Procedure WriteFixed(Value: TFixed);
Var
  IntPart, FracPart: TFixed;
  P: PChar;
  s, s2 : string;
  i : integer;
Begin
  { 1. Get Integer part: Value >> 16 }
  s64shr(IntPart, Value, SHIFT_BITS);

  { 2. Get Fractional part: Value % 65536 }
  s64mod(FracPart, Value, OneFixed);
  
  { Handle negative fraction }
  if s64cmp(FracPart, Zero64) < 0 then
    s64neg(FracPart, FracPart);

  { 3. Convert Integer part to string }
  s64toa(IntPart, StrBuf);
  
  P := StrBuf;
  s := '';
  i := 0;
  WHILE p[i] <> #0 DO BEGIN
    s := s + p[i];
    INC(i);
  END;
  s := s + '.';

  { 4. Print Fractional part }
  { We want 4 digits. Math: (FracPart * 10000) / 65536 }
  s64mul(FracPart, FracPart, Scale10k);
  s64div(FracPart, FracPart, OneFixed);
  
  s64toa(FracPart, StrBuf);
  
  { Copy fraction string }
  P := StrBuf;
  s2 := '';
  i := 0;
  WHILE p[i] <> #0 DO BEGIN
    s2 := s2 + p[i];
    INC(i);
  END;
  
  { Pad with '0' to ensure 4 decimal places (e.g. "0005" instead of "5") }
  While Length(s2) < 4 do s2 := '0' + s2;
  
  s := s + s2;
  
  { Align output }
  Write(s:8);
End;

{ Fixed-Point Multiplication: Res := (A * B) >> 16 }
Procedure FixedMul(Var Res: TFixed; A, B: TFixed);
Var
  Temp: TFixed;
Begin
  s64mul(Temp, A, B);
  s64shr(Res, Temp, SHIFT_BITS);
End;

{ Calculate Distance }
Procedure CalcDistance(Var Res: UInt64; X1, Y1, X2, Y2: TFixed);
Var
  DX, DY: TFixed;
Begin
  s64sub(DX, X1, X2);
  if s64cmp(DX, Zero64) < 0 then s64neg(DX, DX);
  
  s64sub(DY, Y1, Y2);
  if s64cmp(DY, Zero64) < 0 then s64neg(DY, DY);

  u64add(Res, DX, DY);
End;

{ =========================================================================== }
{  Main Program                                                               }
{ =========================================================================== }
Begin
  Writeln('=== LMath32 Library Demo64: Ballistic Simulator ===');
  Writeln('Format: 64-bit Fixed-Point 48.16 (High Precision)');
  Writeln('Scale: 1.0 = 65536');
  Writeln('---------------------------------------------------------------------');
  Writeln('Step |  Pos X   |  Pos Y   |  Vel X   |  Vel Y   | Action');
  Writeln('-----+----------+----------+----------+----------+-------');

  { 1. Initialization }
  MakeInt64(Zero64,     0, 0);
  MakeInt64(OneFixed,   0, 65536);    { 1.0 }
  MakeInt64(Scale10k,   0, 10000);    { For output scaling }
  
  { Recalculated Physics Constants for 16-bit shift }
  { Old Gravity (25/256 = 0.097). New: 0.097 * 65536 = 6400 }
  MakeInt64(Gravity,    0, 6400);
  
  { Old Wind (-5/256 = -0.019). New: -0.019 * 65536 = -1280 }
  MakeInt64(Wind,      -1, -1280);
  
  { Friction 0.99 * 65536 = 64880 }
  MakeInt64(Friction,   0, 64880);
  
  { Bounce 0.5 * 65536 = 32768 }
  MakeInt64(Bounce,     0, 32768);
  
  { Ground friction 0.8 * 65536 = 52428 }
  MakeInt64(Const204,   0, 52428);

  { Limits }
  IntToFixed(Limit50, 50);
  IntToFixed(LimitNeg50, -50);
  IntToFixed(Limit150, 150);
  IntToFixed(Limit10, 10);

  { Start State }
  IntToFixed(PosX, 0);
  IntToFixed(PosY, 50);
  IntToFixed(VelX, 15);
  IntToFixed(VelY, 20);

  TimeStep := 0;
  MakeInt64(TotalDist, 0, 0);
  LastX := PosX;
  LastY := PosY;

  { Simulation Loop }
  Repeat
    Inc(TimeStep);
    Write(TimeStep:4, ' | ');
    
    WriteFixed(PosX); Write(' | ');
    WriteFixed(PosY); Write(' | ');
    WriteFixed(VelX); Write(' | ');
    WriteFixed(VelY); Write(' | ');

    { Physics }
    s64sub(VelY, VelY, Gravity);
    s64add(VelX, VelX, Wind);
    FixedMul(VelX, VelX, Friction);
    FixedMul(VelY, VelY, Friction);
    s64add(PosX, PosX, VelX);
    s64add(PosY, PosY, VelY);

    { Collision }
    If s64cmp(PosY, Zero64) <= 0 Then
    Begin
      Write('BOUNCE!');
      PosY := Zero64;
      s64neg(VelY, VelY);
      FixedMul(VelY, VelY, Bounce);
      FixedMul(VelX, VelX, Const204);
      
      If (s64cmp(VelY, Limit50) < 0) and (s64cmp(VelY, LimitNeg50) > 0) Then
        VelY := Zero64;
    End
    Else
    Begin
      Write('Fly...');
    End;
    
    Writeln;

    { Stats }
    CalcDistance(TempDist, LastX, LastY, PosX, PosY);
    u64add(TotalDist, TotalDist, TempDist);
    LastX := PosX;
    LastY := PosY;

  Until (s64cmp(PosX, Limit150) > 0) OR 
        ( (s64cmp(VelY, Zero64) = 0) and 
          (s64cmp(PosY, Zero64) = 0) and 
          (s64cmp(VelX, Limit10) < 0) );

  Writeln('---------------------------------------------------------------------');
  Writeln('Simulation Finished.');
  
  Write('Total Distance (approx 48.16 units): ');
  u64toa(TotalDist, StrBuf);
  Write(StrBuf);
  Writeln;
End.

