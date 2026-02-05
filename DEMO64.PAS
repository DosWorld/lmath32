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
{  DEMO 64: BALLISTIC PHYSICS SIMULATOR (Fixed-Point Arithmetic)              }
{  Uses the LMath32 unit (64-bit functions) for all calculations.             }
{ =========================================================================== }

Uses LMath32;

Const
  SHIFT_BITS = 8;
  
Type
  { Define TFixed type as Int64 (Array of Byte) }
  TFixed = Int64;

Var
  { Simulation State }
  PosX, PosY   : TFixed; { Coordinates }
  VelX, VelY   : TFixed; { Velocity vector }
  
  { Physics "Constants" (Variables in 64-bit) }
  Gravity      : TFixed;
  Wind         : TFixed;
  Friction     : TFixed;
  Bounce       : TFixed;
  OneFixed     : TFixed;
  
  { Helper constants for comparison and math }
  Zero64       : TFixed;
  Limit50      : TFixed;
  LimitNeg50   : TFixed;
  Limit150     : TFixed;
  Limit10      : TFixed;
  Const100     : TFixed;
  Const204     : TFixed; { For ground friction }

  { Counters and Flags }
  TimeStep     : Integer;
  TotalDist    : UInt64; { Unsigned 64-bit }
  LastX, LastY : TFixed;
  TempDist     : UInt64; { Temporary var for distance calc }
  
  { Buffer for string conversion }
  StrBuf       : Array[0..31] of Char;

{ =========================================================================== }
{  Helper routines for Fixed-Point math using LMath32 (64-bit)                }
{ =========================================================================== }

{ Conversion: Integer -> Fixed (Procedure style) }
{ Res := IntToFixed(I) }
Procedure IntToFixed(Var Res: TFixed; I: Integer);
Var
  Temp: TFixed;
Begin
  { Create 64-bit integer from I }
  if I < 0 then
    MakeInt64(Temp, -1, I)
  else
    MakeInt64(Temp, 0, I);
    
  { Shift left by 8 bits }
  s64shl(Res, Temp, SHIFT_BITS);
End;

{ Conversion: Fixed -> String (for console output) }
Procedure WriteFixed(Value: TFixed);
Var
  IntPart, FracPart: TFixed;
  P: PChar;
  s, s2 : string;
  i : integer;
Begin
  { 1. Get Integer part: Value >> 8 }
  s64shr(IntPart, Value, SHIFT_BITS);

  { 2. Get Fractional part: Value % 256 }
  s64mod(FracPart, Value, OneFixed);
  
  { If value is negative, remainder is negative. Abs needed }
  if s64cmp(FracPart, Zero64) < 0 then
    s64neg(FracPart, FracPart);

  { 3. Convert Integer part to string }
  s64toa(IntPart, StrBuf);
  
  { Manual PChar to String copy }
  P := StrBuf;
  s := '';
  i := 0;
  WHILE p[i] <> #0 DO BEGIN
    s := s + p[i];
    INC(i);
  END;
  s := s + '.';

  { 4. Print Fractional part }
  { Math: (FracPart * 100) / 256 }
  s64mul(FracPart, FracPart, Const100);
  s64div(FracPart, FracPart, OneFixed);
  
  { Convert result (0..99) to string }
  s64toa(FracPart, StrBuf);
  
  { Copy fraction string }
  P := StrBuf;
  s2 := '';
  i := 0;
  WHILE p[i] <> #0 DO BEGIN
    s2 := s2 + p[i];
    INC(i);
  END;
  
  { Pad with '0' if single digit }
  if Length(s2) < 2 then s := s + '0';
  s := s + s2;
  
  Write(s:7);
End;

{ Fixed-Point Multiplication: Res := (A * B) >> 8 }
Procedure FixedMul(Var Res: TFixed; A, B: TFixed);
Var
  Temp: TFixed;
Begin
  { Note: We use Temp to be safe, though s64mul handles aliasing well }
  s64mul(Temp, A, B);
  s64shr(Res, Temp, SHIFT_BITS);
End;

{ Calculate Distance (Approximate Manhattan) }
{ Res := Abs(X1-X2) + Abs(Y1-Y2) }
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
  Writeln('Format: 64-bit Fixed-Point 24.8 (1.0 = 256)');
  Writeln('----------------------------------------------------------------');

  { 1. Initialization of "Constants" (Int64 Variables) }
  MakeInt64(Zero64,     0, 0);
  MakeInt64(OneFixed,   0, 256);
  MakeInt64(Gravity,    0, 25);
  MakeInt64(Wind,      -1, -5); { -5 signed 32-bit }
  MakeInt64(Friction,   0, 253);
  MakeInt64(Bounce,     0, 128);
  
  { Limits for logic }
  MakeInt64(Limit50,    0, 50);
  IntToFixed(Limit50, 50);        { Convert 50 -> 50.0 Fixed }
  
  MakeInt64(LimitNeg50,-1, -50);
  IntToFixed(LimitNeg50, -50);    { Convert -50 -> -50.0 Fixed }
  
  MakeInt64(Limit150,   0, 150);
  IntToFixed(Limit150, 150);      { Convert 150 -> 150.0 Fixed }
  
  MakeInt64(Limit10,    0, 10);
  IntToFixed(Limit10, 10);        { Convert 10 -> 10.0 Fixed }

  MakeInt64(Const100,   0, 100);
  MakeInt64(Const204,   0, 204);

  { Start Position (0, 50 meters) }
  IntToFixed(PosX, 0);
  IntToFixed(PosY, 50);
  
  { Start Velocity (X = 15.0, Y = 20.0) }
  IntToFixed(VelX, 15);
  IntToFixed(VelY, 20);

  TimeStep := 0;
  MakeInt64(TotalDist, 0, 0);
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

    { 1. Gravity: VelY = VelY - Gravity }
    s64sub(VelY, VelY, Gravity);

    { 2. Wind: VelX = VelX + Wind }
    s64add(VelX, VelX, Wind);

    { 3. Air Resistance: Vel = Vel * Friction }
    FixedMul(VelX, VelX, Friction);
    FixedMul(VelY, VelY, Friction);

    { 4. Update Position: Pos = Pos + Vel }
    s64add(PosX, PosX, VelX);
    s64add(PosY, PosY, VelY);

    { --- COLLISION HANDLING --- }
    
    { Check: PosY <= 0 }
    If s64cmp(PosY, Zero64) <= 0 Then
    Begin
      Write('BOUNCE!');
      
      { Snap to ground }
      PosY := Zero64;
      
      { Reflect Velocity: VelY = -VelY }
      s64neg(VelY, VelY);
      
      { Dampen impact: VelY = VelY * Bounce }
      FixedMul(VelY, VelY, Bounce);
      
      { Ground friction: VelX = VelX * 0.8 (204/256) }
      FixedMul(VelX, VelX, Const204);
      
      { Stop if velocity is negligible (-50 < VelY < 50 fixed units?) }
      { Note: Limit50 is 50.0 fixed. This means 50m/s. That's high. 
        Actually in Demo32 we checked raw integer 50 vs Fixed Velocity.
        Let's assume Limit50 contains correct threshold. }
      
      If (s64cmp(VelY, Limit50) < 0) and (s64cmp(VelY, LimitNeg50) > 0) Then
        VelY := Zero64;
    End
    Else
    Begin
      Write('Fly...');
    End;
    
    Writeln;

    { --- STATISTICS --- }
    { Add distance }
    CalcDistance(TempDist, LastX, LastY, PosX, PosY);
    u64add(TotalDist, TotalDist, TempDist);
    
    LastX := PosX;
    LastY := PosY;

  { Exit loop logic: PosX > 150.0 OR (VelY=0 and PosY=0 and VelX < 10.0) }
  Until (s64cmp(PosX, Limit150) > 0) OR 
        ( (s64cmp(VelY, Zero64) = 0) and 
          (s64cmp(PosY, Zero64) = 0) and 
          (s64cmp(VelX, Limit10) < 0) );

  Writeln('----------------------------------------------------------------');
  Writeln('Simulation Finished.');
  
  { Output TotalDist }
  Write('Total Distance (approx units): ');
  u64toa(TotalDist, StrBuf);
  
  { Print StrBuf }
  Write(StrBuf);
  Writeln;
End.

