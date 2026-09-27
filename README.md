# 8-bit Synchronous FIFO Design and Verification using SystemVerilog

## Overview

This project implements an 8-bit synchronous FIFO (First-In First-Out) and verifies its functionality using SystemVerilog.

The FIFO has a data width of 8 bits and a depth of 8 entries.

A SystemVerilog-based verification environment is developed to generate randomized read and write transactions, drive them to the FIFO, monitor the outputs, compare the actual results with expected results using a reference queue, and collect functional coverage.

---

## FIFO Operations

The FIFO supports the following operations:

| Operation | Condition | Description |
|-----------|-----------|-------------|
| WRITE | `wr_en && !full` | Stores input data into the FIFO |
| READ | `rd_en && !empty` | Reads the oldest data from the FIFO |
| FULL | `count == DEPTH` | Indicates FIFO is full |
| EMPTY | `count == 0` | Indicates FIFO is empty |

---

## Inputs and Outputs

### Inputs

| Signal | Width | Description |
|--------|-------|-------------|
| clk | 1-bit | System clock |
| rst | 1-bit | Reset signal |
| wr_en | 1-bit | Write enable |
| rd_en | 1-bit | Read enable |
| din | 8-bit | Input data |

### Outputs

| Signal | Width | Description |
|--------|-------|-------------|
| dout | 8-bit | Output data |
| full | 1-bit | Indicates FIFO is full |
| empty | 1-bit | Indicates FIFO is empty |

---

## Design

The FIFO is implemented using SystemVerilog `always_ff`.

The design uses:

- Memory array for data storage
- Write pointer
- Read pointer
- Occupancy counter
- Full flag
- Empty flag

The FIFO follows the First-In First-Out principle, ensuring that the earliest written data is read first.

---

## Verification Environment

The verification environment is developed using SystemVerilog classes.

### Verification Components

- Transaction
- Generator
- Driver
- Monitor
- Scoreboard
- Environment
- Interface
- Functional Coverage
- SystemVerilog Assertions
- Reference Queue

### Verification Flow

```text
Randomized Transaction
        |
        v
    Generator
        |
        v
      Mailbox
        |
        v
      Driver
        |
        v
       FIFO
        |
        v
      Monitor
        |
        v
      Mailbox
        |
        v
    Scoreboard
        |
        v
 Expected vs Actual
        |
        v
     PASS / FAIL
