# Morse Code Translator (8086 Assembly)

This project was developed as part of the **CSE 341: Microprocessors** course at **BRAC University**.

It is an **8086 Assembly-based Morse Code Translator** that can encode and decode messages, display Morse code mappings, and generate sound signals for dots and dashes.

---

##  Features

*  Encode English text → Morse Code
*  Decode Morse Code → English text
*  Built-in Morse Code lookup table
*  Sound output (beeps for dots and dashes)
*  Adjustable speed (Fast / Medium / Slow)
*  Interactive menu-driven interface with input validation

---

## How It Works

The program uses:

* Lookup-based translation for encoding
* Pattern matching logic for decoding Morse sequences
* BIOS and DOS interrupts for:

  * Keyboard input
  * Screen output
  * Sound generation

👉 The system includes both **encoding and decoding modules**, along with a structured menu system 

---

##  Menu Options

```
1. Encode Message
2. Decode Morse Code
3. Show Morse Code Table
4. Exit
```

---

##  Requirements

* EMU8086 (or any compatible 8086 emulator)

---

##  How to Run

1. Open the `.asm` file in **EMU8086**
2. Assemble the code
3. Run the program
4. Follow the on-screen menu instructions

---

##  Project Structure

```
├── Code.asm
└── README.md
```

---

##  Team Members

* Swapnil Rob
* Nafisa Hasan
* Ahad Islam Shanto

---

##  Course Information

* Course: CSE 341 – Microprocessors
* Institution: BRAC University
* Semester: Summer 2025
