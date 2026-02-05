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
Program Demo32;

{ =========================================================================== }
{  DEMO: BALLISTIC PHYSICS SIMULATOR (Fixed-Point Arithmetic)                 }
{  Uses the Math32.obj library for all 32-bit calculations.                   }
{ =========================================================================== }

Uses LMath32;

Const
  { Constants for Fixed-Point 24.8 format }
  SHIFT_BITS = 8;
  ONE_FIXED  = 256;  { 1.0 in Fixed representation (1 << 8) }
  
  { Physics Settings }
  GRAVITY_VAL = 25;  { ~0.1 in Fixed (0.1 * 256) }
  WIND_VAL    = -5;  { Slight wind to the left }
  FRICTION    = 253; { 0.99 (Air resistance coefficient) }
  BOUNCE      = 128; { 0.5 (Bounciness/Elasticity coefficient) }

Type
  { Define TFixed type for clarity, physically it is Int32 }
  TFixed = Int32;

Var
  { Simulation State }
  PosX, PosY   : TFixed; { Coordinates }
  VelX, VelY   : TFixed; { Velocity vector }
  Gravity      : TFixed;
  Wind         : TFixed;
  
  { Counters and Flags }
  TimeStep     : Integer;
  TotalDist    : UInt32; { Using Unsigned to test u32 functions }
  LastX, LastY : TFixed;
  
  { Buffer for string conversion }
  StrBuf       : Array[0..31] of Char;

{ =========================================================================== }
{  Helper routines for Fixed-Point math using Math32                          }
{ =========================================================================== }

{ Conversion: Integer -> Fixed }
Function IntToFixed(I: Integer): TFixed;
Begin
  { Shift left by 8 bits: I * 256 }
  { Test: s32shl }
  IntToFixed := s32shl(LongInt(I), SHIFT_BITS);
End;

{ Conversion: Fixed -> String (for console output) }
{ Format: "Integer.Fraction" }
Procedure WriteFixed(Value: TFixed);
Var
  IntPart, FracPart: Int32;
  Temp: Int32;
  P: PChar;
  s, s2 : string;
  i : integer;
Begin
  { 1. Get Integer part: Value >> 8 }
  { Test: s32shr (Arithmetic shift to preserve sign) }
  IntPart := s32shr(Value, SHIFT_BITS);

  { 2. Get Fractional part: Value % 256 }
  { Test: s32mod }
  FracPart := s32mod(Value, ONE_FIXED);
  
  { If value is negative, remainder is negative. We need absolute value for printing }
  If FracPart < 0 Then 
    FracPart := -FracPart; { Standard Pascal unary minus, or s32neg }

  { 3. Convert Integer part to string using library }
  { Test: s32toa }
  s32toa(IntPart, StrBuf);
  
  { Print Buffer (ASCIIZ) manually }
  P := StrBuf;
  s := '';
  i := 0;
  WHILE p[i] <> #0 DO BEGIN
          s := s + p[i];
          INC(i);
  END;
  s := s + '.';

  { 4. Print Fractional part (Simplified: 100/256 approx 0.39) }
  { Scale 0..255 to 0..99 for nice 2-digit display }
  Temp := LongInt(FracPart) * 100 Div 256;
  If Temp < 10 Then s := s + '0';
  Str(Temp, s2);
  s := s + s2;
  Write(s:7);
End;

{ Fixed-Point Multiplication: (A * B) >> 8 }
Function FixedMul(A, B: TFixed): TFixed;
Var
  Temp: TFixed;
Begin
  { Test: s32mul }
  Temp := s32mul(A, B);
  { Result of 24.8 * 24.8 is 48.16. Shift right by 8 to get back to 24.8 }
  FixedMul := s32shr(Temp, SHIFT_BITS);
End;

{ Fixed-Point Division: (A << 8) / B }
Function FixedDiv(A, B: TFixed): TFixed;
Var
  Temp: TFixed;
Begin
  { Test: s32shl and s32div }
  Temp := s32shl(A, SHIFT_BITS);
  FixedDiv := s32div(Temp, B);
End;

{ Calculate Distance (Approximate Manhattan) to test Unsigned Math }
Function CalcDistance(X1, Y1, X2, Y2: TFixed): UInt32;
Var
  DX, DY: TFixed;
Begin
  { DX = Abs(X1 - X2) }
  DX := s32sub(X1, X2);
  If DX < 0 Then DX := s32neg(DX); { Test: s32neg }
  
  DY := s32sub(Y1, Y2);
  If DY < 0 Then DY := s32neg(DY);

  { Sum of absolutes (Manhattan distance) for speed }
  { Test: u32add }
  CalcDistance := u32add(UInt32(DX), UInt32(DY));
End;

{ =========================================================================== }
{  Main Program                                                               }
{ =========================================================================== }
Begin
  Writeln('=== LMath32 Library Demo32: Ballistic Simulator ===');
  Writeln('Format: Fixed-Point 24.8 (1.0 = 256)');
  Writeln('----------------------------------------------------------------');

  { 1. Initialization }
  Gravity := GRAVITY_VAL; 
  Wind    := WIND_VAL;
  
  { Start Position (0, 50 meters) }
  PosX := IntToFixed(0);
  PosY := IntToFixed(50);
  
  { Start Velocity (Shot to the right and up) }
  { X = 15.0, Y = 20.0 }
  VelX := IntToFixed(15);
  VelY := IntToFixed(20);

  TimeStep := 0;
  TotalDist := 0;
  LastX := PosX;
  LastY := PosY;

  Writeln('Step | Pos X   | Pos Y   | Vel X   | Vel Y   | Action');
  Writeln('-----+---------+---------+---------+---------+-------');

  { Simulation Loop }
  Repeat
    Inc(TimeStep);
    Write(TimeStep:4, ' | ');
    
    { Output current state }
    WriteFixed(PosX); Write(' | ');
    WriteFixed(PosY); Write(' | ');
    WriteFixed(VelX); Write(' | ');
    WriteFixed(VelY); Write(' | ');

    { --- PHYSICS --- }

    { 1. Apply Gravity: VelY = VelY - Gravity }
    { Test: s32sub }
    VelY := s32sub(VelY, Gravity);

    { 2. Apply Wind: VelX = VelX + Wind }
    { Test: s32add }
    VelX := s32add(VelX, Wind);

    { 3. Apply Air Resistance: Vel = Vel * 0.99 }
    { Test: s32mul (inside FixedMul) }
    VelX := FixedMul(VelX, FRICTION);
    VelY := FixedMul(VelY, FRICTION);

    { 4. Update Position: Pos = Pos + Vel }
    PosX := s32add(PosX, VelX);
    PosY := s32add(PosY, VelY);

    { --- COLLISION HANDLING --- }
    
    { Check: PosY <= 0 (Ground) }
    { Test: s32cmp }
    If s32cmp(PosY, 0) <= 0 Then
    Begin
      Write('BOUNCE!');
      
      { Snap to ground }
      PosY := 0;
      
      { Reflect Velocity: VelY = -VelY }
      { Test: s32neg }
      VelY := s32neg(VelY);
      
      { Dampen impact energy: VelY = VelY * 0.5 }
      VelY := FixedMul(VelY, BOUNCE);
      
      { Ground friction: VelX = VelX * 0.8 }
      VelX := FixedMul(VelX, 204); { 0.8 * 256 = 204.8 }
      
      { Stop if velocity is negligible }
      If (VelY < 50) and (VelY > -50) Then VelY := 0;
    End
    Else
    Begin
      Write('Fly...');
    End;
    
    Writeln;

    { --- STATISTICS (Unsigned Test) --- }
    { Accumulate total distance traveled }
    TotalDist := u32add(TotalDist, CalcDistance(LastX, LastY, PosX, PosY));
    LastX := PosX;
    LastY := PosY;

  { Exit loop if object flies too far right OR stops on the ground }
  Until (s32cmp(PosX, IntToFixed(150)) > 0) OR ((VelY = 0) and (PosY = 0) and (VelX < 10));

  Writeln('----------------------------------------------------------------');
  Writeln('Simulation Finished.');
  
  { Output TotalDist (Unsigned conversion test) }
  Write('Total Distance (approx units): ');
  { Test: u32toa }
  u32toa(TotalDist, StrBuf);
  Writeln(StrBuf);
End.

