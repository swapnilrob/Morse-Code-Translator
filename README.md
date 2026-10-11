<p align="center">
  <img src="https://img.shields.io/badge/8086-Assembly-critical?style=for-the-badge&logo=intel&logoColor=white" alt="8086 Assembly" />
  <img src="https://img.shields.io/badge/EMU8086-Emulator-blue?style=for-the-badge" alt="EMU8086" />
  <img src="https://img.shields.io/badge/Lines-1800+-yellow?style=for-the-badge" alt="1800+ Lines" />
  <img src="https://img.shields.io/badge/DOS-Interrupts-green?style=for-the-badge" alt="DOS Interrupts" />
  <img src="https://img.shields.io/badge/License-Academic-lightgrey?style=for-the-badge" alt="License" />
</p>

<h1 align="center">📡 Morse Code Translator</h1>

<p align="center">
  <strong>Encode text to Morse. Decode Morse to text. Hear every dot and dash.</strong>
</p>

<p align="center">
  A complete bidirectional Morse code translator written entirely in <strong>8086 Assembly</strong> (COMPACT memory model) — 1,800+ lines of hand-crafted low-level code using BIOS and DOS interrupts for I/O, sound generation, and real-time timing control.
</p>

---

## 📌 Why This Project Stands Out

Writing a Morse code translator in a high-level language takes a few dozen lines. Writing one in **8086 Assembly** — with audio output, adjustable speed, input validation, a binary-tree decoder, and a polished menu system — is a fundamentally different challenge.

This project demonstrates:

- **Bare-metal programming** — no libraries, no OS abstractions, just registers, interrupts, and memory
- **Real-time sound synthesis** — PC speaker beeps timed precisely with BIOS timer ticks (`INT 1Ah`) for dots, dashes, and word gaps
- **Algorithm design under constraint** — a hand-built binary decision tree decoder that maps dot/dash sequences (length 1–6) back to characters using only compare-and-jump instructions
- **Full I/O handling** — keyboard input with backspace support, screen output, and keyboard buffer management via direct BIOS data area manipulation

---

## ✨ Features

| Feature | How It Works |
|---------|-------------|
| **Encode (Text → Morse)** | Character-by-character lookup with per-letter sound + visual output |
| **Decode (Morse → Text)** | Binary decision tree matches dot/dash patterns of length 1–6 |
| **Sound Output** | PC speaker beeps via `INT 10h` teletype — sends ASCII `BEL` (07h) to trigger the speaker |
| **Speed Control** | 3 modes (Fast / Medium / Slow) using BIOS timer tick multipliers |
| **Morse Code Table** | Built-in reference display for A–Z, 0–9, and punctuation |
| **Input Validation** | Handles uppercase, lowercase (auto-converts), spaces, backspace |
| **Menu-Driven UI** | Clean ASCII-art interface with looping menu system |

---

## 🏗️ Architecture

```
                        ┌─────────────────────┐
                        │      MAIN MENU      │
                        │  1. Encode           │
                        │  2. Decode           │
                        │  3. Morse Table      │
                        │  4. Exit             │
                        └────────┬────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                  ▼
     ┌────────────────┐ ┌────────────────┐ ┌──────────────┐
     │    ENCODER     │ │    DECODER     │ │  MORSE TABLE │
     │                │ │                │ │              │
     │ For each char: │ │ Read dot/dash  │ │ Static data  │
     │ 1. Lookup      │ │ sequences,     │ │ block with   │
     │ 2. Print dots/ │ │ split by space │ │ all mappings │
     │    dashes      │ │ & slash, then: │ │ displayed    │
     │ 3. Play beep   │ │                │ │ via INT 21h  │
     │    sequence    │ │ Binary tree    │ └──────────────┘
     │ 4. Delay per   │ │ pattern match  │
     │    speed mode  │ │ (len 1→6)     │
     └────────────────┘ └────────────────┘

     Sound Engine (shared):
     ┌──────────────────────────────────────┐
     │ BEEPS (dot)  → BEL + short delay    │
     │ BEEPL (dash) → BEL + 3× dot delay  │
     │ DELAYW (word gap) → 7× dot delay   │
     │ Timer: INT 1Ah (BIOS tick counter)  │
     │ Speed: multiplier × tick count      │
     └──────────────────────────────────────┘
```

---

## 🔧 Technical Deep Dive

### Encoding Engine

Each character (A–Z, 0–9, `.` `,` `?` `!`) has a dedicated `PLAY_X` procedure that:
1. Sets the beep frequency (`MOV AX, 3043` / `MOV STOR, AX`)
2. Calls `BEEPS` (dot) or `BEEPL` (dash) in the correct sequence
3. Calls `BEEPSPACE` to print a visual separator
4. Calls `DELAYS` between elements

Lowercase input is auto-converted to uppercase via `SUB AL, 20h` (ASCII arithmetic).

### Decoding Engine

The decoder uses a **binary decision tree** — no lookup tables, no hashing. For each Morse character (separated by spaces, words separated by `/`):

1. Read the dot/dash sequence into `INPUT_CHECKER`
2. Branch by sequence length (1–6)
3. Within each length, walk a tree of `CMP`/`JE` instructions that follow each dot-or-dash position

This is how the processor sees `.-`:

```
LEN2 → first symbol is '.' → L2DOT → second symbol is '-' → PRINT_A ✓
```

### Timing System

Sound timing is driven by the **BIOS tick counter** (`INT 1Ah`, ~18.2 ticks/second):

| Element | Duration | Formula |
|---------|----------|---------|
| Dot | `SPEED` ticks | Base unit |
| Dash | `SPEED × 3` ticks | Standard Morse ratio |
| Word gap | `SPEED × 7` ticks | Standard Morse ratio |

Where `SPEED` = 1 (Fast), 2 (Medium), or 3 (Slow).

### Interrupt Usage

| Interrupt | Function | Purpose |
|-----------|----------|---------|
| `INT 21h, AH=09h` | Print string | Menu and prompt display |
| `INT 21h, AH=01h` | Read char with echo | User input |
| `INT 21h, AH=02h` | Print character | Dot/dash/letter output |
| `INT 10h, AH=0Eh` | BIOS teletype (BEL) | Sound generation |
| `INT 10h, AH=00h` | Set video mode | Screen clearing |
| `INT 1Ah, AH=00h` | Get tick count | Timing and delays |

---

## 📟 Supported Characters

```
┌──────────────────────────────────────────────┐
│  LETTERS (A–Z)                               │
│  A .-      B -...    C -.-.    D -..         │
│  E .       F ..-.    G --.     H ....        │
│  I ..      J .---    K -.-     L .-..        │
│  M --      N -.      O ---     P .--.        │
│  Q --.-    R .-.     S ...     T -           │
│  U ..-     V ...-    W .--     X -..-        │
│  Y -.--    Z --..                            │
├──────────────────────────────────────────────┤
│  DIGITS (0–9)                                │
│  0 -----   1 .----   2 ..---   3 ...--       │
│  4 ....-   5 .....   6 -....   7 --...       │
│  8 ---..   9 ----.                           │
├──────────────────────────────────────────────┤
│  PUNCTUATION                                 │
│  . .-.-.-    , --..--    ? ..--..    ! -.-.-- │
└──────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- **[EMU8086](https://emu8086.en.lo4d.com/windows)** — 8086 microprocessor emulator (Windows)
- Alternatively: any compatible 8086/8088 emulator (TASM + DOSBox, MASM, etc.) — note that the source uses `COMPACT` memory model and `.COM`-style entry

### Run the Program

```
1. Open EMU8086
2. File → Open → select "Code.asm"
3. Click "Emulate" (or press F5)
4. Click "Run" in the emulator window
5. Follow the on-screen menu
```

### Quick Test

**Encode:** Select option `1` → Type `HELLO` → See `.... . .-.. .-.. ---` with beeps

**Decode:** Select option `2` → Type `.... . .-.. .-.. ---` (spaces between letters) → See `HELLO`

---

## 📁 Project Structure

```
Morse-Code-Translator/
├── Morse Code Translator/
│   └── Code.asm          # Complete 8086 assembly source (1,814 lines)
└── README.md
```

### Code Organization (inside `Code.asm`)

| Section | Lines | Purpose |
|---------|-------|---------|
| `.DATA` segment | 1–128 | Variables, input buffers, string constants, Morse table |
| `MAIN_MENU` | 138–173 | Menu display and option dispatch |
| `_ENCODE` | 177–1096 | Encoder: input, letter lookup, beep routines, delay/timer |
| `_DECODE` | 1101–1787 | Decoder: input parsing, binary tree matcher, character printer |
| `_MORSECODE` | 1805–1810 | Morse code reference table display |
| Sound routines | 998–1096 | `BEEPS`, `BEEPL`, `DELAYS`, `DELAYL`, `DELAYW`, `CLR_KEYB` |

---

## 👥 Team

| Name | Contributions |
|------|---------------|
| Ahad Islam Shanto | Decode engine — designed and implemented the binary decision tree pattern matcher (700+ lines of CMP/JE branching for length 1–6 sequences), input parser for dot/dash/space/slash tokenization |
| Nafisa Hasan | Encode engine — built per-character `PLAY_X` procedures for A–Z, 0–9 and punctuation, integrated `BEEPS`/`BEEPL` sound calls with visual output, lowercase auto-conversion via ASCII arithmetic |
| Swapnil Rob | System architecture — menu system with ASCII-art UI, keyboard I/O with backspace handling, 3-mode speed control via BIOS tick counter (`INT 1Ah`), delay engine, keyboard buffer management |

---

## 📄 Course Context

Developed for **CSE 341 — Microprocessors** at **BRAC University** (Summer 2025). The project demonstrates practical application of 8086 assembly programming concepts including memory segmentation, procedure calls, interrupt-driven I/O, and real-time timing control.

---

## 🧠 What We Learned

- **Register management** — juggling `AX`, `BX`, `CX`, `DX`, `SI`, `DI` across deeply nested procedures without a stack frame convention
- **Interrupt-driven I/O** — using DOS and BIOS services for keyboard, display, and sound without any standard library
- **Timing precision** — implementing variable-speed delays using the BIOS tick counter rather than busy-wait loops
- **Low-level debugging** — tracing execution flow through 1,800+ lines of assembly with no debugger breakpoints or print statements
- **Algorithm adaptation** — implementing a decision tree decoder using only compare-and-jump, since there are no switch statements, hash maps, or arrays of function pointers in 8086 assembly

---

## 📜 License

This project was developed for academic purposes as part of BRAC University's CSE 341 curriculum.
