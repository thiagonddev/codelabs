# Bash

Small, interactive shell exercises for practicing Bash fundamentals.

## Exercises

| File | What it explores |
| --- | --- |
| [`variables.sh`](intro/variables.sh) | Variable assignment, reading terminal input and expanding variables in strings. |
| [`conditions.sh`](intro/conditions.sh) | Reading input, validating a whole-number value, comparing numbers and using conditional branches. |

## Requirements

- Bash
- An interactive terminal

## Run

From this directory:

```bash
bash intro/variables.sh
bash intro/conditions.sh
```

Both exercises are interactive and wait for input.

### `variables.sh`

Prompts for a name and prints a short greeting using variables defined in the script.

### `conditions.sh`

Demonstrates a simple ATM withdrawal flow. It starts with a fixed balance of 1,000, accepts a positive whole-number withdrawal amount, validates the input and prints the resulting balance when the withdrawal is valid.

The balance is stored in memory and resets every time the script runs. This is an introductory exercise, not a real banking or financial application.

## Scope

These scripts are intentionally small examples for learning shell syntax and control flow. They are not intended to provide reusable command-line interfaces or production functionality.
