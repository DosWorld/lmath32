# LMath32: 32-bit & 64-bit Arithmetic Library for Turbo Pascal

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-DOS%20(16--bit)-orange.svg)
![Assembly](https://img.shields.io/badge/language-NASM%20%2F%20Pascal-green.svg)
![AI Assisted](https://img.shields.io/badge/AI-Assisted-purple.svg)

**LMath32** is a highly optimized, low-level assembly library that brings robust **32-bit** and **64-bit** signed/unsigned integer arithmetic to 16-bit Turbo Pascal applications. Written in 8086 Assembly (NASM dialect), it provides a bridge to perform com

plex high-precision calculations on legacy hardware with maximum efficiency.

## 🚀 Features

*   **Complete Arithmetic Suite:** `ADD`, `SUB`, `MUL`, `DIV`, `MOD`, `NEG`.
*   **Dual Mode Support:** Explicit support for **Signed** (`s32`/`s64`) and **Unsigned** (`u32`/`u64`) operations.
*   **64-bit Support:** Full implementation of 64-bit integer arithmetic (`Int64`) on 16-bit processors.
*   **Bitwise Operations:** Logical shifts (`SHL`, `SHR`) and Arithmetic shifts (`SAR`) for signed integers.
*   **Comparisons:** 3-way comparison functions returning -1, 0, or 1.
*   **String Conversion:** Fast routines to convert 32/64-bit integers to ASCIIZ strings (decimal).
*   **Pascal Interface:** Fully typed `Unit` using the `FAR CALL` convention for seamless integration.

## 💡 Why use LMath32?

While Turbo Pascal 7.0 provides the `LongInt` (32-bit) and `Comp` (64-bit FPU) types, **LMath32** offers unique advantages:

1.  **64-bit Integer Math:** Perform 64-bit integer calculations (`Int64`) directly on the CPU without relying on the FPU or the floating-point `Comp` type.
2.  **Unsigned Arithmetic:** TP7 lacks native unsigned types larger than 16-bit (`Word`). LMath32 unlocks the full range of `UInt32` and `UInt64`.
3.  **Fixed-Point Math:** The precise control over bitwise shifts makes this library ideal for implementing Fixed-Point arithmetic (e.g., 24.8 or 16.16 formats) for high-performance physics or graphics on 8086/286 machines.
4.  **Performance:** Hand-tuned assembly kernels for division and multiplication.

## 🎮 The Demos: Ballistic Physics Simulator

Included are two demo programs (`DEMO32` and `DEMO64`) that showcase the library's capabilities by simulating a cannonball shot.

*   **Technique:** Uses **Fixed-Point Arithmetic (24.8 format)**, where 256 equals 1.0. This allows simulating fractional physics using only integer instructions.
*   **Simulation:** Calculates projectile motion considering:
    *   **Gravity:** Constant downward force.
    *   **Wind:** Lateral force affecting trajectory.
    *   **Air Resistance (Friction):** Velocity damping over time.
    *   **Elastic Collision:** Bouncing off the ground with energy loss.
*   **Visualization:** Outputs the calculated X/Y coordinates and Velocity vectors to the console in real-time.

## 🛠️ Build Instructions

You need the following tools:
*   **NASM** (The Netwide Assembler)
*   **Turbo Pascal Compiler** (`tpc.exe`) or **Free Pascal** (`fpc` in TP mode)
*   **Make**

### Cloning

```bash
git clone https://github.com/DosWorld/lmath32.git
cd lmath32
```

### Compiling

Simply run `make` to build the library and the demos.

```bash
make
```

This will:
1.  Assemble `lmath32.asm` and `lmath64.asm` into OBJ files.
2.  Compile `lmath32.pas` (linking the OBJs).
3.  Compile `demo32.pas` and `demo64.pas`.

### Running

Below is the actual output from `DEMO32.EXE`. The simulation runs until the object leaves the screen area (X > 150).

```text
C:\> DEMO32.EXE
=== LMath32 Library Demo32: Ballistic Simulator ===
Format: Fixed-Point 24.8 (1.0 = 256)
----------------------------------------------------------------
Step | Pos X   | Pos Y   | Vel X   | Vel Y   | Action
-----+---------+---------+---------+---------+-------
   1 |    0.00 |   50.00 |   15.00 |   20.00 | Fly...
   2 |   14.80 |   69.66 |   14.80 |   19.66 | Fly...
   3 |   29.41 |   89.00 |   14.60 |   19.33 | Fly...
   4 |   43.83 |  108.02 |   14.41 |   19.01 | Fly...
   5 |   58.05 |  126.71 |   14.22 |   18.69 | Fly...
   6 |   72.09 |  145.09 |   14.03 |   18.37 | Fly...
   7 |   85.94 |  163.16 |   13.85 |   18.06 | Fly...
   8 |   99.61 |  180.92 |   13.66 |   17.75 | Fly...
   9 |  113.10 |  198.37 |   13.48 |   17.45 | Fly...
  10 |  126.41 |  215.52 |   13.30 |   17.14 | Fly...
  11 |  139.54 |  232.37 |   13.13 |   16.84 | Fly...
----------------------------------------------------------------
Simulation Finished.
Total Distance (approx units): 89965

C:\
```

The 64-bit demo produces physics results using `Int64` types:

```text
C:\> DEMO64.EXE
=== LMath32 Library Demo64: Ballistic Simulator ===
Format: 64-bit Fixed-Point 48.16 (High Precision)
Scale: 1.0 = 65536
---------------------------------------------------------------------
Step |  Pos X   |  Pos Y   |  Vel X   |  Vel Y   | Action
-----+----------+----------+----------+----------+-------
   1 |   0.0000 |  50.0000 |  15.0000 |  20.0000 | Fly...
   2 |  14.8305 |  69.7031 |  14.8305 |  19.7031 | Fly...
   3 |  29.4932 |  89.1123 |  14.6627 |  19.4092 | Fly...
   4 |  43.9898 | 108.2305 |  14.4966 |  19.1182 | Fly...
   5 |  58.3220 | 127.0607 |  14.3321 |  18.8301 | Fly...
   6 |  72.4913 | 145.6057 |  14.1693 |  18.5450 | Fly...
   7 |  86.4995 | 163.8684 |  14.0081 |  18.2626 | Fly...
   8 | 100.3481 | 181.8516 |  13.8486 |  17.9832 | Fly...
   9 | 114.0388 | 199.5581 |  13.6906 |  17.7065 | Fly...
  10 | 127.5730 | 216.9907 |  13.5342 |  17.4325 | Fly...
  11 | 140.9525 | 234.1521 |  13.3794 |  17.1614 | Fly...
---------------------------------------------------------------------
Simulation Finished.
Total Distance (approx 48.16 units): 23279950

C:\
```

## 📦 API Overview

The library exposes functions via the `LMath32` unit. All functions use the Pascal calling convention (Far Calls).

### 32-bit Operations
Standard functional interface.

```pascal
Function s32add(A, B: Int32): Int32;
Function s32div(A, B: Int32): Int32;
Function s32shl(Val: Int32; C: Integer): Int32;
Procedure s32toa(Val: Int32; Buf: PChar);
```

### 64-bit Operations
Procedural interface (Results passed by Reference/VAR for performance).

```pascal
{ Arithmetic: Res := A op B }
Procedure s64add(Var Res, A, B: Int64);
Procedure s64mul(Var Res, A, B: Int64);

{ Bitwise }
Procedure s64shl(Var Res, Val: Int64; Count: Word);
Procedure s64shr(Var Res, Val: Int64; Count: Word);

{ Comparison: Returns -1, 0, 1 }
Function s64cmp(Var A, B: Int64): Integer;

{ Helper }
Procedure MakeInt64(Var Res: Int64; Hi, Lo: LongInt);
```

## 📄 License

Copyright © **DosWorld**.

This project is licensed under the **MIT License** - see the [LICENSE.TXT](LICENSE.TXT) file for details.
