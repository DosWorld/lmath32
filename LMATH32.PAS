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
{  Math32 Library Interface                                                   }
{  Low-level 32-bit Integer Arithmetic for 16-bit Turbo Pascal.               }
{                                                                             }
{  Dependencies: MATH32.OBJ (NASM compiled with -f obj)                       }
{ =========================================================================== }

Interface

Type
  { Turbo Pascal 7.0 'LongInt' is a 32-bit signed integer (-2B to +2B). }
  { We define Int32 and UInt32 aliases for clarity. }
  
  Int32  = LongInt;  { Signed 32-bit Integer }
  UInt32 = LongInt;  { Unsigned 32-bit Integer (treated as bit container) }
  
{ =========================================================================== }
{  ARITHMETIC OPERATIONS                                                      }
{ =========================================================================== }

{ --------------------------------------------------------------------------- }
{  s32add                                                                     }
{  Description: Adds two 32-bit integers.                                     }
{  Input:       A (Int32) - First operand.                                    }
{               B (Int32) - Second operand.                                   }
{  Returns:     (Int32)   - The sum (A + B).                                  }
{ --------------------------------------------------------------------------- }
Function s32add(A, B: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  u32add                                                                     }
{  Description: Adds two Unsigned 32-bit integers.                            }
{  Input:       A (UInt32) - First operand.                                   }
{               B (UInt32) - Second operand.                                  }
{  Returns:     (UInt32)   - The sum (A + B).                                 }
{ --------------------------------------------------------------------------- }
Function u32add(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32sub                                                                     }
{  Description: Subtracts two 32-bit integers.                                }
{  Input:       A (Int32) - Minuend.                                          }
{               B (Int32) - Subtrahend.                                       }
{  Returns:     (Int32)   - The difference (A - B).                           }
{ --------------------------------------------------------------------------- }
Function s32sub(A, B: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  u32sub                                                                     }
{  Description: Subtracts two Unsigned 32-bit integers.                       }
{  Input:       A (UInt32) - Minuend.                                         }
{               B (UInt32) - Subtrahend.                                      }
{  Returns:     (UInt32)   - The difference (A - B).                          }
{ --------------------------------------------------------------------------- }
Function u32sub(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32neg                                                                     }
{  Description: Negates a Signed 32-bit integer (Two's Complement).           }
{  Input:       A (Int32) - Value to negate.                                  }
{  Returns:     (Int32)   - The negative value (-A).                          }
{ --------------------------------------------------------------------------- }
Function s32neg(A: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  s32mul                                                                     }
{  Description: Multiplies two Signed 32-bit integers.                        }
{  Input:       A (Int32) - Multiplicand.                                     }
{               B (Int32) - Multiplier.                                       }
{  Returns:     (Int32)   - The product (A * B).                              }
{ --------------------------------------------------------------------------- }
Function s32mul(A, B: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  u32mul                                                                     }
{  Description: Multiplies two Unsigned 32-bit integers.                      }
{  Input:       A (UInt32) - Multiplicand.                                    }
{               B (UInt32) - Multiplier.                                      }
{  Returns:     (UInt32)   - The product (A * B).                             }
{ --------------------------------------------------------------------------- }
Function u32mul(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32div                                                                     }
{  Description: Divides two Signed 32-bit integers.                           }
{  Input:       A (Int32) - Dividend.                                         }
{               B (Int32) - Divisor.                                          }
{  Returns:     (Int32)   - The quotient (A / B).                             }
{  Note:        Returns 0FFFFFFFFh (-1) if Divisor is 0.                      }
{ --------------------------------------------------------------------------- }
Function s32div(A, B: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  u32div                                                                     }
{  Description: Divides two Unsigned 32-bit integers.                         }
{  Input:       A (UInt32) - Dividend.                                        }
{               B (UInt32) - Divisor.                                         }
{  Returns:     (UInt32)   - The quotient (A / B).                            }
{  Note:        Returns 0FFFFFFFFh if Divisor is 0.                           }
{ --------------------------------------------------------------------------- }
Function u32div(A, B: UInt32): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32mod                                                                     }
{  Description: Calculates the remainder of Signed division.                  }
{  Input:       A (Int32) - Dividend.                                         }
{               B (Int32) - Divisor.                                          }
{  Returns:     (Int32)   - The remainder (A % B).                            }
{  Note:        The sign of the result follows the sign of the Dividend (A).  }
{ --------------------------------------------------------------------------- }
Function s32mod(A, B: Int32): Int32; far;

{ --------------------------------------------------------------------------- }
{  u32mod                                                                     }
{  Description: Calculates the remainder of Unsigned division.                }
{  Input:       A (UInt32) - Dividend.                                        }
{               B (UInt32) - Divisor.                                         }
{  Returns:     (UInt32)   - The remainder (A % B).                           }
{ --------------------------------------------------------------------------- }
Function u32mod(A, B: UInt32): UInt32; far;

{ =========================================================================== }
{  BITWISE OPERATIONS                                                         }
{ =========================================================================== }

{ --------------------------------------------------------------------------- }
{  s32shl / u32shl                                                            }
{  Description: Logical Shift Left.                                           }
{  Input:       Val   (Int32)   - Value to shift.                             }
{               Count (Integer) - Number of bits to shift (0..31).            }
{  Returns:     (Int32)         - Result of (Val << Count).                   }
{  Note:        If Count >= 32, returns 0.                                    }
{ --------------------------------------------------------------------------- }
Function s32shl(Val: Int32; Count: Integer): Int32; far;
Function u32shl(Val: UInt32; Count: Integer): UInt32; far;

{ --------------------------------------------------------------------------- }
{  u32shr                                                                     }
{  Description: Logical Shift Right (Unsigned). Fills with zeros.             }
{  Input:       Val   (UInt32)  - Value to shift.                             }
{               Count (Integer) - Number of bits to shift (0..31).            }
{  Returns:     (UInt32)        - Result of (Val >> Count).                   }
{ --------------------------------------------------------------------------- }
Function u32shr(Val: UInt32; Count: Integer): UInt32; far;

{ --------------------------------------------------------------------------- }
{  s32shr                                                                     }
{  Description: Arithmetic Shift Right (Signed). Fills with sign bit.         }
{  Input:       Val   (Int32)   - Value to shift.                             }
{               Count (Integer) - Number of bits to shift (0..31).            }
{  Returns:     (Int32)         - Result of (Val >> Count) preserving sign.   }
{ --------------------------------------------------------------------------- }
Function s32shr(Val: Int32; Count: Integer): Int32; far;

{ =========================================================================== }
{  COMPARISON OPERATIONS                                                      }
{ =========================================================================== }

{ --------------------------------------------------------------------------- }
{  s32cmp                                                                     }
{  Description: Compares two Signed 32-bit integers.                          }
{  Input:       A (Int32) - First integer.                                    }
{               B (Int32) - Second integer.                                   }
{  Returns:     (Integer) - Comparison result:                                }
{                             -1 if A < B                                     }
{                              0 if A = B                                     }
{                              1 if A > B                                     }
{ --------------------------------------------------------------------------- }
Function s32cmp(A, B: Int32): Integer; far;

{ --------------------------------------------------------------------------- }
{  u32cmp                                                                     }
{  Description: Compares two Unsigned 32-bit integers.                        }
{  Input:       A (UInt32) - First integer.                                   }
{               B (UInt32) - Second integer.                                  }
{  Returns:     (Integer)  - Comparison result:                               }
{                             -1 if A < B                                     }
{                              0 if A = B                                     }
{                              1 if A > B                                     }
{ --------------------------------------------------------------------------- }
Function u32cmp(A, B: UInt32): Integer; far;

{ =========================================================================== }
{  STRING CONVERSION                                                          }
{ =========================================================================== }

{ --------------------------------------------------------------------------- }
{  s32toa                                                                     }
{  Description: Converts a Signed 32-bit integer to a null-terminated string. }
{  Input:       Val    (Int32)   - Value to convert.                          }
{               Buffer (PChar) - Pointer to destination buffer.               }
{  Output:      Buffer is filled with the ASCIIZ string (e.g., "-12345"#0).   }
{  Warning:     Buffer must be at least 12 bytes long to avoid overflow.      }
{ --------------------------------------------------------------------------- }
Procedure s32toa(Val: Int32; Buffer: PChar); far;

{ --------------------------------------------------------------------------- }
{  u32toa                                                                     }
{  Description: Converts an Unsigned 32-bit integer to a null-term string.    }
{  Input:       Val    (UInt32)  - Value to convert.                          }
{               Buffer (PChar) - Pointer to destination buffer.               }
{  Output:      Buffer is filled with the ASCIIZ string (e.g., "12345"#0).    }
{  Warning:     Buffer must be at least 11 bytes long to avoid overflow.      }
{ --------------------------------------------------------------------------- }
Procedure u32toa(Val: UInt32; Buffer: PChar); far;

Implementation

{ Link the external Object File }
{$L LMATH32.OBJ}
{$F+}
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
Function u32shr; external;
Function s32shr; external;

Function s32cmp; external;
Function u32cmp; external;

Procedure s32toa; external;
Procedure u32toa; external;

End.

