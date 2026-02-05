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
UNIT LMATH32;

{ =========================================================================== }
{  LMath32 Unit                                                               }
{  Unified Low-level 32-bit and 64-bit Integer Arithmetic for Turbo Pascal.   }
{                                                                             }
{  Target:      16-bit MS-DOS (8086 CPU)                                      }
{  Dependencies: LMATH32.OBJ, LMATH64.OBJ (NASM compiled with -f obj)         }
{ =========================================================================== }

INTERFACE

Type
  { ------------------------------------------------------------------------- }
  { 32-bit Types                                                              }
  { Turbo Pascal 7.0 'LongInt' is a 32-bit signed integer.                    }
  { ------------------------------------------------------------------------- }
  Int32  = LongInt;  { Signed 32-bit Integer (-2B .. +2B) }
  UInt32 = LongInt;  { Unsigned 32-bit Integer (0 .. 4B) }

  { ------------------------------------------------------------------------- }
  { 64-bit Types                                                              }
  { Represented as an 8-byte array to ensure size and avoid FPU usage (Comp). }
  { ------------------------------------------------------------------------- }
  Int64  = Array[1..8] of Byte; { Signed 64-bit Integer }
  UInt64 = Int64;               { Unsigned 64-bit Integer }

  PBuffer = PChar;

{ =========================================================================== }
{  32-BIT ARITHMETIC OPERATIONS                                               }
{ =========================================================================== }

{ --------------------------------------------------------------------------- }
{  s32add / u32add                                                            }
{  Description: Adds two 32-bit integers.                                     }
{  Returns:     (Int32) The sum (A + B).                                      }
{ --------------------------------------------------------------------------- }
Function s32add(A, B: Int32): Int32; far;
Function u32add(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32sub / u32sub                                                            }
{  Description: Subtracts two 32-bit integers.                                }
{  Returns:     (Int32) The difference (A - B).                               }
{ --------------------------------------------------------------------------- }
Function s32sub(A, B: Int32): Int32; far;
Function u32sub(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32neg                                                                     }
{  Description: Negates a Signed 32-bit integer.                              }
{  Returns:     (Int32) The negative value (-A).                              }
{ --------------------------------------------------------------------------- }
Function s32neg(A: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  s32mul / u32mul                                                            }
{  Description: Multiplies two 32-bit integers.                               }
{  Returns:     (Int32) The product (A * B).                                  }
{ --------------------------------------------------------------------------- }
Function s32mul(A, B: Int32): Int32; far;
Function u32mul(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32div / u32div                                                            }
{  Description: Divides two 32-bit integers.                                  }
{  Returns:     (Int32) The quotient (A / B).                                 }
{  Note:        Returns -1 (FFFFFFFF) if Divisor is 0.                        }
{ --------------------------------------------------------------------------- }
Function s32div(A, B: Int32): Int32; far;
Function u32div(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32mod / u32mod                                                            }
{  Description: Calculates the remainder of 32-bit division.                  }
{  Returns:     (Int32) The remainder (A % B).                                }
{ --------------------------------------------------------------------------- }
Function s32mod(A, B: Int32): Int32; far;
Function u32mod(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32shl / u32shl                                                            }
{  Description: Logical Shift Left (32-bit).                                  }
{  Returns:     (Int32) Result of (Val << Count).                             }
{ --------------------------------------------------------------------------- }
Function s32shl(Val: Int32; Count: Integer): Int32; far;
Function u32shl(Val: UInt32; Count: Integer): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32shr / u32shr                                                            }
{  Description: Shift Right (32-bit).                                         }
{  s32shr:      Arithmetic Shift (Preserves Sign).                            }
{  u32shr:      Logical Shift (Zero Fill).                                    }
{  Returns:     (Int32) Result of (Val >> Count).                             }
{ --------------------------------------------------------------------------- }
Function s32shr(Val: Int32; Count: Integer): Int32; far;
Function u32shr(Val: UInt32; Count: Integer): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32cmp / u32cmp                                                            }
{  Description: Compares two 32-bit integers.                                 }
{  Returns:     -1 if A < B, 0 if A = B, 1 if A > B.                          }
{ --------------------------------------------------------------------------- }
Function s32cmp(A, B: Int32): Integer; far;
Function u32cmp(A, B: UInt32): Integer; far;

{ --------------------------------------------------------------------------- }
{  s32toa / u32toa                                                            }
{  Description: Converts a 32-bit integer to a null-terminated string.        }
{  Output:      Buffer filled with ASCIIZ string. Min size: 12 bytes.         }
{ --------------------------------------------------------------------------- }
Procedure s32toa(Val: Int32; Buffer: PBuffer); far;
Procedure u32toa(Val: UInt32; Buffer: PBuffer); far;


{ =========================================================================== }
{  64-BIT ARITHMETIC OPERATIONS                                               }
{  Note: All parameters are passed by VAR (Reference) for performance.        }
{ =========================================================================== }

{ --------------------------------------------------------------------------- }
{  s64add / u64add                                                            }
{  Description: Adds two 64-bit integers.                                     }
{  Input:       A, B (Int64/UInt64)                                           }
{  Output:      Res := A + B                                                  }
{ --------------------------------------------------------------------------- }
Procedure s64add(Var Res, A, B: Int64); far;
Procedure u64add(Var Res, A, B: UInt64); far;

{ --------------------------------------------------------------------------- }
{  s64sub / u64sub                                                            }
{  Description: Subtracts two 64-bit integers.                                }
{  Input:       A (Minuend), B (Subtrahend)                                   }
{  Output:      Res := A - B                                                  }
{ --------------------------------------------------------------------------- }
Procedure s64sub(Var Res, A, B: Int64); far;
Procedure u64sub(Var Res, A, B: UInt64); far;

{ --------------------------------------------------------------------------- }
{  s64neg                                                                     }
{  Description: Negates a Signed 64-bit integer.                              }
{  Input:       A (Value)                                                     }
{  Output:      Res := -A                                                     }
{ --------------------------------------------------------------------------- }
Procedure s64neg(Var Res, A: Int64); far;

{ --------------------------------------------------------------------------- }
{  s64mul / u64mul                                                            }
{  Description: Multiplies two 64-bit integers.                               }
{  Input:       A, B (Operands)                                               }
{  Output:      Res := A * B                                                  }
{ --------------------------------------------------------------------------- }
Procedure s64mul(Var Res, A, B: Int64); far;
Procedure u64mul(Var Res, A, B: UInt64); far;

{ --------------------------------------------------------------------------- }
{  s64div / u64div                                                            }
{  Description: Divides two 64-bit integers.                                  }
{  Input:       A (Dividend), B (Divisor)                                     }
{  Output:      Res := A / B                                                  }
{ --------------------------------------------------------------------------- }
Procedure s64div(Var Res, A, B: Int64); far;
Procedure u64div(Var Res, A, B: UInt64); far;

{ --------------------------------------------------------------------------- }
{  s64mod / u64mod                                                            }
{  Description: Calculates remainder of 64-bit division.                      }
{  Input:       A (Dividend), B (Divisor)                                     }
{  Output:      Res := A % B                                                  }
{ --------------------------------------------------------------------------- }
Procedure s64mod(Var Res, A, B: Int64); far;
Procedure u64mod(Var Res, A, B: UInt64); far;

{ --------------------------------------------------------------------------- }
{  s64shl / u64shl                                                            }
{  Description: Logical Shift Left (64-bit).                                  }
{  Input:       Val (Int64), Count (Word)                                     }
{  Output:      Res := Val << Count                                           }
{ --------------------------------------------------------------------------- }
Procedure s64shl(Var Res, Val: Int64; Count: Word); far;
Procedure u64shl(Var Res, Val: UInt64; Count: Word); far;

{ --------------------------------------------------------------------------- }
{  s64shr / u64shr                                                            }
{  Description: Shift Right (64-bit).                                         }
{  s64shr:      Arithmetic Shift (Preserves Sign).                            }
{  u64shr:      Logical Shift (Zero Fill).                                    }
{  Input:       Val (Int64), Count (Word)                                     }
{  Output:      Res := Val >> Count                                           }
{ --------------------------------------------------------------------------- }
Procedure s64shr(Var Res, Val: Int64; Count: Word); far;
Procedure u64shr(Var Res, Val: UInt64; Count: Word); far;

{ --------------------------------------------------------------------------- }
{  s64cmp / u64cmp                                                            }
{  Description: Compares two 64-bit integers.                                 }
{  Returns:     -1 if A < B, 0 if A = B, 1 if A > B.                          }
{ --------------------------------------------------------------------------- }
Function s64cmp(Var A, B: Int64): Integer; far;
Function u64cmp(Var A, B: UInt64): Integer; far;

{ --------------------------------------------------------------------------- }
{  s64toa / u64toa                                                            }
{  Description: Converts a 64-bit integer to a null-terminated string.        }
{  Output:      Buffer filled with ASCIIZ string. Min size: 22 bytes.         }
{ --------------------------------------------------------------------------- }
Procedure s64toa(Var Val: Int64; Buffer: PBuffer); far;
Procedure u64toa(Var Val: UInt64; Buffer: PBuffer); far;

{ --------------------------------------------------------------------------- }
{  MakeInt64                                                                  }
{  Description: Helper to construct Int64 from two 32-bit halves.             }
{  Input:       Hi, Lo (LongInt)                                              }
{  Output:      Res (Int64)                                                   }
{ --------------------------------------------------------------------------- }
Procedure MakeInt64(VAR Res : Int64; Hi, Lo: LongInt);


IMPLEMENTATION

{$L LMATH32.OBJ}
{$L LMATH64.OBJ}

{$F+} { Force Far Calls }

{ 32-bit Externals }
Function s32add; external;
Function u32add; external;
Function s32sub; external;
Function u32sub; external;
Function s32neg; external;
Function s32mul; external;
Function u32mul; external;
Function s32div; external;
Function u32div; external;
Function s32mod; external;
Function u32mod; external;
Function s32shl; external;
Function u32shl; external;
Function s32shr; external;
Function u32shr; external;
Function s32cmp; external;
Function u32cmp; external;
Procedure s32toa; external;
Procedure u32toa; external;

{ 64-bit Externals }
Procedure s64add; external;
Procedure u64add; external;
Procedure s64sub; external;
Procedure u64sub; external;
Procedure s64neg; external;
Procedure s64mul; external;
Procedure u64mul; external;
Procedure s64div; external;
Procedure u64div; external;
Procedure s64mod; external;
Procedure u64mod; external;
Procedure s64shl; external;
Procedure u64shl; external;
Procedure s64shr; external;
Procedure u64shr; external;
Function s64cmp; external;
Function u64cmp; external;
Procedure s64toa; external;
Procedure u64toa; external;

{ Pascal Helper }
Procedure MakeInt64(VAR Res : Int64; Hi, Lo: LongInt);
Type
  TRec = Record L, H: LongInt; End;
Begin
  TRec(Res).L := Lo;
  TRec(Res).H := Hi;
End;

End.

