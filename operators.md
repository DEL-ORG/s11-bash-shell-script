# Bash Operators — Complete Reference

A practical reference of every operator you'll use in Bash, with simple runnable examples. Copy any snippet and try it yourself.

---

## Table of Contents

1. [Assignment Operators](#1-assignment-operators)
2. [Arithmetic Operators](#2-arithmetic-operators)
3. [Comparison Operators (Numbers)](#3-comparison-operators-numbers)
4. [Comparison Operators (Strings)](#4-comparison-operators-strings)
5. [Logical Operators](#5-logical-operators)
6. [File Test Operators](#6-file-test-operators)
7. [String Test Operators](#7-string-test-operators)
8. [Redirection Operators](#8-redirection-operators)
9. [Pipe Operator](#9-pipe-operator)
10. [Control Operators](#10-control-operators)
11. [Bitwise Operators](#11-bitwise-operators)
12. [Parameter Expansion Operators](#12-parameter-expansion-operators)
13. [Pattern Matching Operators](#13-pattern-matching-operators)

---

## 1. Assignment Operators

Used to assign values to variables. **No spaces around the `=` sign.**

| Operator | Meaning | Example |
|---|---|---|
| `=` | Assign | `name="Tia"` |
| `+=` | Append / add | `count+=1` |
| `-=` | Subtract (integers) | `count-=1` |
| `*=` | Multiply (integers) | `count*=2` |
| `/=` | Divide (integers) | `count/=2` |
| `%=` | Modulo (integers) | `count%=3` |

```bash
# Basic assignment
name="Alex"
echo "$name"          # Alex

# String append
greeting="Hello"
greeting+=" World"
echo "$greeting"      # Hello World

# Integer math (requires declare -i or use (( )))
declare -i count=10
count+=5
echo "$count"         # 15

count-=3
echo "$count"         # 12

count*=2
echo "$count"         # 24
```

---

## 2. Arithmetic Operators

Used inside `$(( ))` or `(( ))` for math.

| Operator | Meaning | Example |
|---|---|---|
| `+` | Addition | `$((5 + 3))` → 8 |
| `-` | Subtraction | `$((5 - 3))` → 2 |
| `*` | Multiplication | `$((5 * 3))` → 15 |
| `/` | Integer division | `$((10 / 3))` → 3 |
| `%` | Modulo (remainder) | `$((10 % 3))` → 1 |
| `**` | Exponent | `$((2 ** 3))` → 8 |
| `++` | Increment | `((count++))` |
| `--` | Decrement | `((count--))` |

```bash
a=10
b=3

echo $((a + b))       # 13
echo $((a - b))       # 7
echo $((a * b))       # 30
echo $((a / b))       # 3  (integer division)
echo $((a % b))       # 1  (remainder)
echo $((a ** 2))      # 100

# Increment / decrement
count=5
((count++))
echo "$count"         # 6

((count--))
echo "$count"         # 5
```

---

## 3. Comparison Operators (Numbers)

Used inside `[[ ]]` or `[ ]` for comparing integers.

| Operator | Meaning | Example |
|---|---|---|
| `-eq` | Equal | `[[ $a -eq $b ]]` |
| `-ne` | Not equal | `[[ $a -ne $b ]]` |
| `-lt` | Less than | `[[ $a -lt $b ]]` |
| `-le` | Less than or equal | `[[ $a -le $b ]]` |
| `-gt` | Greater than | `[[ $a -gt $b ]]` |
| `-ge` | Greater than or equal | `[[ $a -ge $b ]]` |

```bash
a=10
b=20

if [[ $a -eq 10 ]]; then
  echo "a equals 10"
fi

if [[ $a -lt $b ]]; then
  echo "a is less than b"
fi

if [[ $b -ge 20 ]]; then
  echo "b is at least 20"
fi
```

Inside `(( ))` you can also use `==`, `!=`, `<`, `<=`, `>`, `>=` for numbers:

```bash
a=10
if (( a > 5 )); then
  echo "a is greater than 5"
fi
```

---

## 4. Comparison Operators (Strings)

Used inside `[[ ]]` for comparing strings.

| Operator | Meaning | Example |
|---|---|---|
| `==` or `=` | Equal | `[[ "$a" == "$b" ]]` |
| `!=` | Not equal | `[[ "$a" != "$b" ]]` |
| `<` | Less than (alphabetical) | `[[ "$a" < "$b" ]]` |
| `>` | Greater than (alphabetical) | `[[ "$a" > "$b" ]]` |

```bash
env="prod"

if [[ "$env" == "prod" ]]; then
  echo "Production environment"
fi

if [[ "$env" != "dev" ]]; then
  echo "Not dev"
fi

# Alphabetical comparison
name1="Alice"
name2="Bob"
if [[ "$name1" < "$name2" ]]; then
  echo "Alice comes before Bob"
fi
```

**Always quote string variables** in comparisons to avoid bugs when values contain spaces.

---

## 5. Logical Operators

Combine multiple conditions.

| Operator | Meaning | Example |
|---|---|---|
| `&&` | AND | `[[ $a -gt 0 && $a -lt 10 ]]` |
| `||` | OR | `[[ $a -eq 0 || $a -eq 1 ]]` |
| `!` | NOT | `[[ ! -f file.txt ]]` |

```bash
age=25

# AND
if [[ $age -ge 18 && $age -le 65 ]]; then
  echo "Working age"
fi

# OR
env="prod"
if [[ "$env" == "prod" || "$env" == "staging" ]]; then
  echo "Non-dev environment"
fi

# NOT
if [[ ! -f config.yaml ]]; then
  echo "Config file is missing"
fi
```

You can also chain commands with `&&` and `||` outside of `[[ ]]`:

```bash
mkdir /tmp/backup && echo "Directory created"
ping -c 1 google.com || echo "No network"
```

---

## 6. File Test Operators

Used inside `[[ ]]` to check properties of files and directories.

| Operator | Meaning |
|---|---|
| `-e path` | Path exists (any type) |
| `-f path` | Regular file exists |
| `-d path` | Directory exists |
| `-L path` | Symbolic link exists |
| `-r path` | Readable |
| `-w path` | Writable |
| `-x path` | Executable |
| `-s path` | Exists and not empty |
| `-z path` | Exists and empty |
| `file1 -nt file2` | file1 newer than file2 |
| `file1 -ot file2` | file1 older than file2 |

```bash
if [[ -f /etc/hosts ]]; then
  echo "hosts file exists"
fi

if [[ -d /var/log ]]; then
  echo "log directory exists"
fi

if [[ -r config.yaml ]]; then
  echo "config.yaml is readable"
fi

if [[ -x deploy.sh ]]; then
  echo "deploy.sh is executable"
fi

if [[ ! -e backup.tar.gz ]]; then
  echo "No backup found"
fi

# Compare file ages
if [[ new.log -nt old.log ]]; then
  echo "new.log is newer"
fi
```

---

## 7. String Test Operators

Used inside `[[ ]]` to check properties of strings.

| Operator | Meaning |
|---|---|
| `-z "$str"` | String is empty |
| `-n "$str"` | String is not empty |
| `"$str"` | String is not empty (shorthand) |

```bash
name=""

if [[ -z "$name" ]]; then
  echo "Name is empty"
fi

name="Alex"
if [[ -n "$name" ]]; then
  echo "Name is set: $name"
fi

# Shorthand — same as -n
if [[ "$name" ]]; then
  echo "Name has a value"
fi
```

---

## 8. Redirection Operators

Control where command input and output go.

| Operator | Meaning | Example |
|---|---|---|
| `>` | Redirect stdout (overwrite) | `echo hi > file.txt` |
| `>>` | Redirect stdout (append) | `echo hi >> file.txt` |
| `<` | Redirect stdin from file | `wc -l < file.txt` |
| `2>` | Redirect stderr | `cmd 2> errors.log` |
| `2>>` | Append stderr | `cmd 2>> errors.log` |
| `&>` | Redirect stdout and stderr | `cmd &> all.log` |
| `2>&1` | Merge stderr into stdout | `cmd > all.log 2>&1` |
| `<<` | Heredoc (multi-line input) | See below |
| `<<<` | Here-string | `grep foo <<< "$var"` |

```bash
# Write to file (overwrite)
echo "hello" > greeting.txt

# Append to file
echo "world" >> greeting.txt

# Read from file as input
wc -l < greeting.txt

# Send errors to a separate file
ls /nonexistent 2> errors.log

# Send both output and errors to same file
ls /tmp &> output.log

# Discard all output
noisy_command > /dev/null 2>&1

# Heredoc - feed multi-line text into a command
cat << EOF > config.yaml
server: localhost
port: 8080
EOF

# Here-string - feed a string as stdin
grep "error" <<< "this is an error message"
```

---

## 9. Pipe Operator

Send the output of one command as input to the next.

| Operator | Meaning |
|---|---|
| `\|` | Pipe stdout of one command to stdin of the next |
| `\|&` | Pipe both stdout and stderr |

```bash
# Count files in a directory
ls | wc -l

# Find running processes matching a name
ps aux | grep nginx

# Chain multiple commands
cat access.log | grep "404" | sort | uniq -c | sort -rn

# Pipe both stdout and stderr
noisy_command |& grep "error"
```

---

## 10. Control Operators

Control how commands run in sequence.

| Operator | Meaning |
|---|---|
| `;` | Run commands in sequence |
| `&&` | Run next only if previous succeeded |
| `\|\|` | Run next only if previous failed |
| `&` | Run command in background |
| `;;` | End of a `case` branch |

```bash
# Run in sequence (always)
echo "first"; echo "second"; echo "third"

# Run only if previous succeeded
mkdir /tmp/work && cd /tmp/work && echo "Ready"

# Run only if previous failed
ping -c 1 server || echo "Server unreachable"

# Combine both
cmd && echo "success" || echo "failure"

# Run in background
sleep 60 &
echo "Sleeping in background, PID: $!"

# case statement with ;;
action="start"
case "$action" in
  start) echo "Starting" ;;
  stop)  echo "Stopping" ;;
  *)     echo "Unknown" ;;
esac
```

---

## 11. Bitwise Operators

Used inside `$(( ))` or `(( ))` for low-level bit manipulation. You probably won't need these often, but they're here for completeness.

| Operator | Meaning | Example |
|---|---|---|
| `&` | Bitwise AND | `$((5 & 3))` → 1 |
| `\|` | Bitwise OR | `$((5 \| 3))` → 7 |
| `^` | Bitwise XOR | `$((5 ^ 3))` → 6 |
| `~` | Bitwise NOT | `$((~5))` → -6 |
| `<<` | Left shift | `$((1 << 3))` → 8 |
| `>>` | Right shift | `$((16 >> 2))` → 4 |

```bash
echo $((5 & 3))       # 1   (0101 AND 0011 = 0001)
echo $((5 | 3))       # 7   (0101 OR  0011 = 0111)
echo $((5 ^ 3))       # 6   (0101 XOR 0011 = 0110)
echo $((1 << 3))      # 8   (shift left 3 bits = 1000)
echo $((16 >> 2))     # 4   (shift right 2 bits)
```

---

## 12. Parameter Expansion Operators

Manipulate variables inline using `${ }` syntax.

| Operator | Meaning |
|---|---|
| `${var}` | Value of var |
| `${var:-default}` | Use default if var is unset or empty |
| `${var:=default}` | Use default AND assign to var |
| `${var:?error}` | Exit with error if var is unset |
| `${var:+alt}` | Use alt if var IS set |
| `${#var}` | Length of var |
| `${var:offset}` | Substring from offset |
| `${var:offset:length}` | Substring from offset, given length |
| `${var#pattern}` | Remove shortest match from start |
| `${var##pattern}` | Remove longest match from start |
| `${var%pattern}` | Remove shortest match from end |
| `${var%%pattern}` | Remove longest match from end |
| `${var/old/new}` | Replace first match |
| `${var//old/new}` | Replace all matches |
| `${var^^}` | Uppercase all |
| `${var,,}` | Lowercase all |

```bash
name="deployment.yaml"

# Basic expansion
echo "${name}"                # deployment.yaml

# Default values
echo "${missing:-fallback}"   # fallback
echo "${name:-fallback}"      # deployment.yaml

# Length
echo "${#name}"               # 15

# Substring
echo "${name:0:6}"            # deploy
echo "${name:7}"              # nt.yaml

# Remove suffix / prefix
echo "${name%.yaml}"          # deployment
echo "${name#deploy}"         # ment.yaml

# Replace
echo "${name/yaml/json}"      # deployment.json
echo "${name//e/E}"           # dEploymEnt.yaml

# Case conversion
echo "${name^^}"              # DEPLOYMENT.YAML
echo "${name,,}"              # deployment.yaml

# Error if unset
echo "${required:?must be set}"   # exits script if unset
```

---

## 13. Pattern Matching Operators

Used inside `[[ ]]` for glob and regex matching.

| Operator | Meaning |
|---|---|
| `==` | Glob pattern match |
| `!=` | Glob pattern non-match |
| `=~` | Regex match |

```bash
file="deployment.yaml"

# Glob matching with ==
if [[ "$file" == *.yaml ]]; then
  echo "YAML file"
fi

if [[ "$file" == deploy* ]]; then
  echo "Starts with 'deploy'"
fi

# Regex matching with =~
if [[ "$file" =~ ^deploy.*\.yaml$ ]]; then
  echo "Matches the pattern"
fi

# Extract regex capture groups
phone="555-123-4567"
if [[ "$phone" =~ ^([0-9]{3})-([0-9]{3})-([0-9]{4})$ ]]; then
  echo "Area code: ${BASH_REMATCH[1]}"
  echo "Prefix:    ${BASH_REMATCH[2]}"
  echo "Line:      ${BASH_REMATCH[3]}"
fi
```

---

## Quick Reference Cheat Sheet

```bash
# Assignment
x=5                    # assign
x+=2                   # append / add

# Arithmetic
$((a + b))             # math inside $(( ))
((count++))            # increment

# Number comparison
[[ $a -eq $b ]]        # equal
[[ $a -lt $b ]]        # less than
[[ $a -gt $b ]]        # greater than

# String comparison
[[ "$a" == "$b" ]]     # equal
[[ "$a" != "$b" ]]     # not equal
[[ -z "$a" ]]          # empty
[[ -n "$a" ]]          # not empty

# Logical
[[ $a && $b ]]         # AND
[[ $a || $b ]]         # OR
[[ ! $a ]]             # NOT

# File tests
[[ -f file ]]          # regular file exists
[[ -d dir ]]           # directory exists
[[ -r file ]]          # readable
[[ -x file ]]          # executable

# Redirection
cmd > file             # overwrite
cmd >> file            # append
cmd 2> errors          # stderr
cmd &> all             # both
cmd1 | cmd2            # pipe

# Control
cmd1 && cmd2           # run cmd2 if cmd1 succeeds
cmd1 || cmd2           # run cmd2 if cmd1 fails
cmd &                  # run in background

# Parameter expansion
${var:-default}        # default if unset
${#var}                # length
${var%.ext}            # strip suffix
${var/old/new}         # replace first
${var^^}               # uppercase

# Pattern matching
[[ "$f" == *.yaml ]]   # glob
[[ "$s" =~ ^[0-9]+$ ]] # regex
```

---

Keep this file handy while you're learning. The fastest way to internalize these is to open a terminal and try each example yourself — Bash is one of those tools where five minutes of hands-on practice beats an hour of reading.
