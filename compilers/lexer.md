# Lexer in a Nutshell

- [Implementation in Haskell](../implementations/lexer.hs)

## What is a Lexer?
A lexer (or tokenizer) is the component responsible for transforming raw source text into a sequence of tokens.
It represents the first stage in the implementation of a programming language, interpreter, or compiler. Its goal is to read the source code character by character and identify the basic elements of the language.

For example, the expression:
```text
(age + 42) * 5
```
is converted into:
```text
[
  TokOpenParen,
  TokIdent "age",
  TokOp "+",
  TokNum 42,
  TokCloseParen,
  TokOp "*",
  TokNum 5
]
```
The tokens produced by the lexer are later consumed by other stages such as parsers, interpreters, and compilers.

## Processing Pipeline
The processing of a programming language usually begins with lexical analysis:
```text
Source Code
     ↓
Lexer (Tokenizer)
     ↓
Token Stream
     ↓
Parser
     ↓
AST
     ↓
Interpreter or Compiler
```
This document focuses on the lexical analysis stage.

## What is a Token?
A token is the smallest meaningful unit recognized during lexical analysis.
Instead of working directly with raw text, later stages of the pipeline operate on tokens, which carry structured meaning within the language.

Examples:
| Text | Token          |
| ---- | -------------- |
| (    | TokOpenParen   |
| )    | TokCloseParen  |
| +    | TokOp "+"      |
| age  | TokIdent "age" |
| 42   | TokNum 42      |

Each token belongs to a **category** (number, identifier, operator, etc.) and may carry an associated **value** (such as the name of an identifier or the integer value of a number literal).

## How Tokenization Works
During tokenization, the lexer scans the input one character at a time.
Depending on the characters encountered, it identifies different lexical categories:

* Whitespace
* Operators
* Parentheses
* Numbers
* Identifiers
* Special symbols

For example:

Input:
```text
x + 10
```
Output:
```text
[
  TokIdent "x",
  TokOp "+",
  TokNum 10
]
```

### Internal State Machine
A lexer typically operates as a finite state machine. It transitions between states based on the current character being read:

```text
  START
    │
    ├── letter ──────────────> IDENT ── letter/digit ──> IDENT (loop)
    │                              └── other ──> EMIT TokIdent
    │
    ├── digit ───────────────> NUMBER ── digit ──> NUMBER (loop)
    │                               └── other ──> EMIT TokNum
    │
    ├── operator (+, -, *, /) ──────────────────> EMIT TokOp
    │
    ├── '(' ─────────────────────────────────────> EMIT TokOpenParen
    ├── ')' ─────────────────────────────────────> EMIT TokCloseParen
    │
    ├── whitespace ──────────────────────────────> SKIP, back to START
    │
    └── other ───────────────────────────────────> LEXICAL ERROR
```

This design makes lexers efficient and predictable, since each state handles a well-defined subset of characters.

---

## Identifier Recognition
Identifiers represent variable names, function names, or constants.

Example:
```text
age
```
Generated token:
```text
TokIdent "age"
```

An identifier typically starts with a letter and may be followed by letters, digits, or underscores. The lexer keeps consuming characters as long as they match the identifier pattern, emitting a single token at the end.

### Reserved Words (Keywords)
In many languages, certain identifiers are reserved and carry a fixed syntactic meaning. A lexer may check the collected string against a keyword table and emit a specialized token instead of a generic identifier:

```text
"if"    → TokKeyword "if"
"while" → TokKeyword "while"
"myVar" → TokIdent "myVar"
```

This lookup typically happens right after the full identifier is collected, before the token is emitted.

---

## Number Recognition
Consecutive digits are recognized as numeric literals.

Example:
```text
42
```
Generated token:
```text
TokNum 42
```

The lexer groups all consecutive digits before converting them into an integer value.

### Integer vs. Float
Basic lexers handle only integer literals. Supporting floating-point numbers requires also recognizing a decimal point followed by more digits:

```text
3.14  →  TokFloat 3.14
42    →  TokNum 42
```

Adding float support is a natural and common extension.

## Operator Recognition
Mathematical operators are converted into tokens.

Examples:
| Operator | Token     |
| -------- | --------- |
| +        | TokOp "+" |
| -        | TokOp "-" |
| *        | TokOp "*" |
| /        | TokOp "/" |

These tokens are later used by the parser to build expression trees.

### Multi-character Operators
Some languages use operators composed of two or more characters, such as `==`, `!=`, `<=`, `>=`, or `->`. Handling them requires the lexer to perform **lookahead** — peeking at the next character before deciding which token to emit:

```text
'='  followed by '='     →  TokOp "=="
'='  followed by other   →  TokOp "="
'!'  followed by '='     →  TokOp "!="
```

Lookahead of a single character is usually sufficient for most operators.

## Whitespace Handling
Whitespace (spaces, tabs, newlines) is generally not meaningful in expressions and is simply skipped. However, in some languages such as Python, indentation carries syntactic meaning and must be tokenized as `INDENT` and `DEDENT` tokens.

In most cases, whitespace is consumed and discarded:
```text
"  x  +  1  "  →  [ TokIdent "x", TokOp "+", TokNum 1 ]
```

## Lexical Error Handling
If the lexer encounters a character that is not part of the language's alphabet, it produces a lexical error.

Example:

Input:
```text
x @ 10
```
Output:
```text
Lexical Error: Unexpected '@'
```

This prevents invalid input from reaching later stages of the pipeline.

### Error Recovery
A more robust lexer may attempt **error recovery** — instead of stopping at the first unknown character, it skips the offending input, reports the error, and continues tokenizing the rest of the source. This allows all errors to be collected in a single pass, giving better feedback to the user.

## Scope and Limitations
A basic lexer covers the essentials of lexical analysis but commonly omits features needed in production-grade tools:

| Feature               | Notes                                       |
| --------------------- | ------------------------------------------- |
| Integer literals      | Grouping consecutive digits                 |
| Float literals        | Requires decimal point handling             |
| Identifiers           | Letter followed by letters/digits           |
| Keywords              | Post-collection lookup against a table      |
| Single-char operators | +, -, *, /                                  |
| Multi-char operators  | ==, !=, <=; requires lookahead              |
| String literals       | Requires delimiter tracking (e.g. `"..."`) |
| Comments              | Must be recognized and discarded            |
| Error recovery        | Skip and continue vs. halt on first error   |
