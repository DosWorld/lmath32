# LMath32: 32-bit Arithmetic Library for Turbo Pascal (16-bit)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-DOS%20(16--bit)-orange.svg)
![Assembly](https://img.shields.io/badge/language-NASM%20%2F%20Pascal-green.svg)

**LMath32** is a highly optimized, low-level assembly library that
brings robust 32-bit signed and unsigned integer arithmetic to 16-bit
Turbo Pascal applications. Written in 8086 Assembly (NASM dialect),
it provides a bridge to perform complex calculatio ns on legacy hardware
with maximum efficiency.

## 🚀 Features

*   **Complete Arithmetic Suite:** `ADD`, `SUB`, `MUL`, `DIV`, `MOD`, `NEG`.
*   **Dual Mode Support:** Explicit support for both **Signed** (`s32`)
    and **Unsigned** (`u32`) operations.
*   **Bitwise Operations:** Logical shifts (`SHL`, `SHR`) and Arithmetic
    shifts (`SAR`) for signed integers.
*   **Comparisons:** 3-way comparison functions returning -1, 0, or 1.
*   **String Conversion:** Fast routines to convert 32-bit integers to
    ASCIIZ strings (decimal).
*   **Pascal Interface:** Fully typed `Unit` using the `FAR CALL`
    convention for seamless integration.

## 💡 Why use LMath32?

While Turbo Pascal 7.0 provides the `LongInt` type, **LMath32** offers
several advantages for specific use cases:

1.  **Unsigned Arithmetic:** TP7 lacks a native `Cardinal` (32-bit unsigned) type. LMath32 allows you to work with the full 32-bit range (0 to 4,294,967,295).
2.  **Fixed-Point Math:** The precise control over bitwise shifts
    (`s32shr` vs `u32shr`) makes this library ideal for implementing
    Fixed-Point arithmetic (e.g., 24.8 or 16.16 formats) for high-performance
    physics or graphics without a math coprocessor (FPU).
3.  **Educational Value:** A clear example of interfacing modern NASM
    assembly with legacy Pascal code using object files (`.obj`).
4.  **Performance:** Hand-tuned assembly kernels for division and
    multiplication.

## 🎮 The Demo: Ballistic Physics Simulator

Included is a `DEMO.PAS` program that showcases the library's capabilities
by simulating a cannonball shot.

*   **Technique:** Uses **Fixed-Point Arithmetic (24.8 format)**, where
    256 equals 1.0. This allows simulating fractional physics using only
    integer instructions.
*   **Simulation:** Calculates projectile motion considering:
    *   **Gravity:** Constant downward force.
    *   **Wind:** Lateral force affecting trajectory.
    *   **Air Resistance (Friction):** Velocity damping over time.
    *   **Elastic Collision:** Bouncing off the ground with energy loss.
*   **Visualization:** Outputs the calculated X/Y coordinates and Velocity
    vectors to the console in real-time.

> **Note:** The demo runs the simulation loop until the object stops or
leaves the simulation area, then exits automatically.

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

Simply run `make` to build the library and the demo.

```bash
make
```

This will:
1.  Assemble `lmath32.asm` into `LMATH32.OBJ`.
2.  Compile `lmath32.pas` (linking the OBJ).
3.  Compile `demo.pas` into `DEMO.EXE`.

To run the demo:
```bash
C:\demo.exe
=== Math32 Library Demo: Ballistic Simulator ===
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

## 📦 API Overview

The library exposes functions via the `LMath32` unit. All functions use
the Pascal calling convention (Far Calls).

```pascal
{ Arithmetic }
Function s32add(A, B: Int32): Int32;   { A + B }
Function s32sub(A, B: Int32): Int32;   { A - B }
Function s32mul(A, B: Int32): Int32;   { A * B }
Function s32div(A, B: Int32): Int32;   { A / B }
Function s32mod(A, B: Int32): Int32;   { A % B }

{ Bitwise }
{ Left Shift }
Function s32shl(Val: Int32; C: Integer): Int32;
{ Arithmetic Right Shift (Sign fill) }
Function s32shr(Val: Int32; C: Integer): Int32;
{ Logical Right Shift (Zero fill) }
Function u32shr(Val: UInt32; C: Integer): UInt32;

{ Comparison (-1, 0, 1) }
Function s32cmp(A, B: Int32): Integer;

{ Conversion }
Procedure s32toa(Val: Int32; Buf: PChar);
```

*Note: Equivalent `u32*` functions exist for Unsigned integers.*

## 📄 License

Copyright © **DosWorld**.

This project is licensed under the **MIT License** - see
the [LICENSE.TXT](LICENSE.TXT) file for details.

