# Bash Scripting for Beginners

A practical guide for someone starting out in DevOps who wants to automate tasks with Bash.

---

## 1. What Is Bash?

**Bash** stands for **Bourne Again SHell**. It's a command-line interpreter (a "shell") that reads commands you type and tells the operating system what to do. It's the default shell on most Linux distributions and was the default on macOS until Catalina (which switched to zsh).

Two ways you'll use Bash:

1. **Interactively** — typing commands one at a time in a terminal.
2. **As scripts** — saving a series of commands in a `.sh` file so they run automatically.

For DevOps work, scripts are where the real value is. Instead of manually SSH-ing into servers and running 15 commands, you write one script and run it everywhere. This is the starting point for everything from deployment automation to CI/CD pipeline steps — exactly the kind of work you're doing with GitHub Actions, Jenkins, and Kubernetes.

---

## 2. Your First Script

Every Bash script starts with a **shebang** line that tells the system which interpreter to use:

```bash
#!/bin/bash
echo "Hello, DevOps world!"
```

Save this as `hello.sh`, then make it executable and run it:

```bash
chmod +x hello.sh
./hello.sh
```

- `chmod +x` grants execute permission.
- `./` tells the shell to run the file in the current directory.
- `echo` prints text to the terminal.

---

## 3. Variables

Bash variables are untyped — everything is fundamentally a string, but Bash can treat values as numbers, arrays, or associative arrays depending on how you declare and use them.

### 3.1 String Variables

The most common kind. No spaces around the `=` sign — this trips up every beginner.

```bash
name="Tia"
greeting="Hello, $name"
echo "$greeting"   # Hello, Tia
```

Rules worth remembering:

- `name="Tia"` works. `name = "Tia"` does **not** — Bash thinks `name` is a command.
- Use `"$name"` (double quotes) to expand the variable. Single quotes `'$name'` print the literal text `$name`.
- Always quote variables when using them to avoid word-splitting bugs: `echo "$name"`, not `echo $name`.

### 3.2 Integer Variables

Declared with `declare -i` (or just used in arithmetic contexts).

```bash
declare -i count=5
count=count+3
echo "$count"   # 8
```

More commonly you'll see arithmetic done with `$(( ))`:

```bash
a=10
b=3
sum=$((a + b))
echo "$sum"     # 13
```

### 3.3 Constants (Read-Only Variables)

Use `readonly` or `declare -r` when a value must not change — useful for config paths, URLs, cluster names.

```bash
readonly CLUSTER_NAME="prod-eks-govcloud"
CLUSTER_NAME="something-else"   # Error: readonly variable
```

### 3.4 Arrays (Indexed)

A list of values accessed by number (starting at 1).

```bash
namespaces=("abc-api" "jkl-worker" "xyz-db")
echo "${namespaces[1]}"        # abc-api
echo "${namespaces[@]}"        # all elements
echo "${#namespaces[@]}"       # count: 3
```

Loop over an array:

```bash
for ns in "${namespaces[@]}"; do
  echo "Deploying to $ns"
done
```

### 3.5 Associative Arrays (Key-Value Maps)

Like a dictionary or hash map. Requires `declare -A` and Bash 4+.

```bash
declare -A cluster_regions
cluster_regions["prod"]="us-gov-west-1"
cluster_regions["dev"]="us-east-2"

echo "${cluster_regions[prod]}"    # us-gov-west-1
```

### 3.6 Environment Variables

Variables exported into the environment so child processes inherit them. You'll interact with these constantly — `KUBECONFIG`, `AWS_PROFILE`, `PATH`, etc.

```bash
export AWS_PROFILE="govcloud-admin"
```

Without `export`, the variable only exists in the current shell. With it, any command launched from that shell (including `kubectl`, `terraform`, `aws`) can see it.

### 3.7 Special / Built-in Variables

Bash gives you some variables for free inside scripts:

| Variable | Meaning |
|---|---|
| `$0` | The script's own name |
| `$1`, `$2`, ... | Positional arguments passed to the script |
| `$#` | Number of arguments |
| `$@` | All arguments as separate words |
| `$?` | Exit code of the last command (0 = success) |
| `$$` | PID of the current shell |
| `$USER`, `$HOME`, `$PWD` | Current user, home dir, working dir |

Example script `deploy.sh`:

```bash
#!/bin/bash
echo "Script: $0"
echo "Environment: $1"
echo "Total args: $#"
```

Run as `./deploy.sh prod` and you'll see `Environment: prod`.

---

## 4. User Input

Read a value interactively:

```bash
read -p "Enter cluster name: " cluster
echo "You chose: $cluster"
```

For sensitive input like passwords, add `-s` (silent):

```bash
read -s -p "Password: " pw
```

---

## 5. Conditionals

The classic `if` statement:

```bash
if [[ "$env" == "prod" ]]; then
  echo "Deploying to production"
elif [[ "$env" == "dev" ]]; then
  echo "Deploying to dev"
else
  echo "Unknown environment"
fi
```

Common test operators:

| Operator | Meaning |
|---|---|
| `-eq`, `-ne`, `-lt`, `-gt` | Integer comparisons |
| `==`, `!=` | String comparisons |
| `-z "$x"` | String is empty |
| `-n "$x"` | String is not empty |
| `-f path` | File exists |
| `-d path` | Directory exists |
| `-x path` | File is executable |

Use `[[ ]]` (double brackets) — it's safer and more modern than the older `[ ]`.

---

## 6. Loops

**For loop:**

```bash
for pod in $(kubectl get pods -o name); do
  echo "Found: $pod"
done
```

**While loop:**

```bash
count=0
while [[ $count -lt 5 ]]; do
  echo "Attempt $count"
  count=$((count + 1))
done
```

**Until loop** — runs until the condition becomes true. Handy for polling:

```bash
until kubectl get pod my-pod | grep -q Running; do
  echo "Waiting for pod..."
  sleep 2
done
```

---

## 7. Functions

Group reusable logic into functions:

```bash
deploy_service() {
  local service_name="$1"
  local namespace="$2"
  echo "Deploying $service_name to $namespace"
  kubectl apply -f "$service_name.yaml" -n "$namespace"
}

deploy_service "kafka-connect" "abc-streaming"
```

Key points:

- Arguments come in as `$1`, `$2`, etc. — just like script arguments.
- `local` keeps variables scoped to the function. Always use it to avoid polluting the global scope.

---

## 8. Command Substitution

Capture the output of a command into a variable with `$( )`:

```bash
current_context=$(kubectl config current-context)
echo "Using context: $current_context"
```

You'll use this constantly in DevOps scripts to chain tools together.

---

## 9. Exit Codes and Error Handling

Every command returns an exit code. `0` means success, anything else means failure. Check it with `$?`:

```bash
kubectl apply -f deployment.yaml
if [[ $? -ne 0 ]]; then
  echo "Deployment failed"
  exit 1
fi
```

For production scripts, put this at the top to fail fast:

```bash
set -euo pipefail
```

- `-e` — exit immediately if any command fails.
- `-u` — treat unset variables as errors.
- `-o pipefail` — if any command in a pipe fails, the whole pipe fails.

This one line will save you from hours of debugging mysterious half-failed deployments.

---

## 10. Redirection and Pipes

Bash's superpower: stitching commands together.

```bash
command > file.log       # overwrite file with stdout
command >> file.log      # append to file
command 2> errors.log    # redirect stderr
command &> all.log       # redirect both stdout and stderr
command1 | command2      # send output of one command as input to the next
```

Example you'll actually use:

```bash
kubectl get pods -A | grep -v Running | tee broken-pods.log
```

---

## 11. A Realistic Starter Script

Here's everything combined into something you might actually write at work:

```bash
#!/bin/bash
set -euo pipefail

# ----- Config -----
readonly NAMESPACES=("abc-api" "jkl-worker" "xyz-db")
readonly LOG_FILE="/tmp/pod-check-$(date +%Y%m%d).log"

# ----- Functions -----
check_namespace() {
  local ns="$1"
  echo "Checking $ns..."
  local bad_pods
  bad_pods=$(kubectl get pods -n "$ns" --no-headers | grep -v Running | wc -l)

  if [[ "$bad_pods" -gt 0 ]]; then
    echo "  WARNING: $bad_pods non-running pod(s) in $ns"
  else
    echo "  OK"
  fi
}

# ----- Main -----
echo "Pod health check - $(date)" | tee "$LOG_FILE"

for ns in "${NAMESPACES[@]}"; do
  check_namespace "$ns" | tee -a "$LOG_FILE"
done

echo "Done. Log saved to $LOG_FILE"
```

---

## 12. Where to Go Next

Once this feels comfortable, look into:

- **`sed` and `awk`** — text manipulation powerhouses.
- **`grep` with regex** — pattern matching in logs and output.
- **`jq`** — parsing JSON from `kubectl`, `aws`, and API calls.
- **`xargs`** — passing output as arguments to other commands.
- **Trap handlers** (`trap cleanup EXIT`) — graceful cleanup when a script exits.
- **ShellCheck** (https://www.shellcheck.net) — a linter that catches common Bash mistakes. Run it on every script you write. Seriously.

---

## 13. Quick Reference Cheat Sheet

```bash
# Variables
name="value"              # string
declare -i num=5          # integer
readonly CONST="fixed"    # constant
arr=("a" "b" "c")         # indexed array
declare -A map            # associative array
export VAR="x"            # environment variable

# Expansion
"$var"        # quoted (safe)
${var:-default}   # use default if unset
$(command)    # command output
$((a + b))    # arithmetic

# Conditionals
[[ "$x" == "y" ]]
[[ -f /path/to/file ]]
[[ -z "$var" ]]

# Loops
for x in "${arr[@]}"; do ... done
while [[ condition ]]; do ... done

# Safety
set -euo pipefail
```

Keep this file around, experiment in a throwaway directory, and write tiny scripts to automate things you already do by hand — that's the fastest way to learn.
# The Complete Bash Guide

A thorough walkthrough of Bash for someone learning DevOps — from "what is a shell" all the way to writing robust production scripts. Every section has runnable examples.

---

## Table of Contents

1. [What Is Bash?](#1-what-is-bash)
2. [Running Bash: Interactive vs Scripts](#2-running-bash-interactive-vs-scripts)
3. [Your First Script](#3-your-first-script)
4. [The Shebang Line](#4-the-shebang-line)
5. [Comments](#5-comments)
6. [Variables](#6-variables)
    - 6.1 [Declaring and Using Variables](#61-declaring-and-using-variables)
    - 6.2 [String Variables](#62-string-variables)
    - 6.3 [Integer Variables](#63-integer-variables)
    - 6.4 [Read-Only Constants](#64-read-only-constants)
    - 6.5 [Indexed Arrays](#65-indexed-arrays)
    - 6.6 [Associative Arrays](#66-associative-arrays)
    - 6.7 [Environment Variables](#67-environment-variables)
    - 6.8 [Special / Built-in Variables](#68-special--built-in-variables)
    - 6.9 [Parameter Expansion](#69-parameter-expansion)
7. [Quoting Rules](#7-quoting-rules)
8. [User Input](#8-user-input)
9. [Arithmetic](#9-arithmetic)
10. [Conditionals](#10-conditionals)
    - 10.1 [if / elif / else](#101-if--elif--else)
    - 10.2 [Test Operators](#102-test-operators)
    - 10.3 [case Statements](#103-case-statements)
11. [Loops](#11-loops)
    - 11.1 [for Loops](#111-for-loops)
    - 11.2 [while Loops](#112-while-loops)
    - 11.3 [until Loops](#113-until-loops)
    - 11.4 [break and continue](#114-break-and-continue)
12. [Functions](#12-functions)
13. [Command Substitution](#13-command-substitution)
14. [Exit Codes and Error Handling](#14-exit-codes-and-error-handling)
15. [Redirection and Pipes](#15-redirection-and-pipes)
16. [Globbing and Wildcards](#16-globbing-and-wildcards)
17. [String Manipulation](#17-string-manipulation)
18. [Arrays in Depth](#18-arrays-in-depth)
19. [Working with Files](#19-working-with-files)
20. [Text Processing Tools](#20-text-processing-tools)
21. [Process Management](#21-process-management)
22. [Traps and Signals](#22-traps-and-signals)
23. [Debugging Scripts](#23-debugging-scripts)
24. [Best Practices](#24-best-practices)
25. [A Full Realistic Script](#25-a-full-realistic-script)
26. [Cheat Sheet](#26-cheat-sheet)
27. [Where to Go Next](#27-where-to-go-next)

---

## 1. What Is Bash?

**Bash** (Bourne Again SHell) is a command-line interpreter — a program that reads commands and asks the operating system to run them. It's the default shell on most Linux distributions and the scripting language you'll lean on constantly in DevOps work: deployment scripts, CI/CD jobs, container entrypoints, Kubernetes automation, log processing, everything.

Bash descends from the original Bourne shell (`sh`) and is largely compatible with it, but adds arrays, better string handling, arithmetic, and many quality-of-life improvements.

---

## 2. Running Bash: Interactive vs Scripts

- **Interactive mode** — you type commands one at a time at the prompt. Great for exploration and one-off tasks.
- **Script mode** — commands saved in a `.sh` file and executed in sequence. This is what you automate with.

Check which shell you're in:

```bash
echo "$SHELL"       # your login shell
echo "$BASH_VERSION"  # confirms you're actually running bash
```

---

## 3. Your First Script

Create `hello.sh`:

```bash
#!/bin/bash
echo "Hello, DevOps world!"
```

Make it executable and run it:

```bash
chmod +x hello.sh
./hello.sh
```

Output:

```
Hello, DevOps world!
```

---

## 4. The Shebang Line

The first line of a script, starting with `#!`, tells the OS which interpreter to use.

```bash
#!/bin/bash          # use bash at /bin/bash
#!/usr/bin/env bash  # use whichever bash is first on PATH (more portable)
```

Use `#!/usr/bin/env bash` when writing scripts that may run on macOS, Alpine containers, or other systems where `/bin/bash` might not exist or be outdated.

---

## 5. Comments

```bash
# This is a single-line comment

: '
This is a multi-line comment
using the no-op colon command.
'
```

---

## 6. Variables

### 6.1 Declaring and Using Variables

```bash
name="Tia"         # assignment — NO spaces around =
echo "$name"       # Tia
```

Common mistake:

```bash
name = "Tia"   # ERROR — bash thinks `name` is a command
```

### 6.2 String Variables

```bash
first="Hello"
second="World"
greeting="$first, $second!"
echo "$greeting"   # Hello, World!
```

Concatenation is just placing variables next to each other inside quotes.

### 6.3 Integer Variables

Bash is untyped by default, but you can declare integers explicitly:

```bash
declare -i count=5
count=count+3
echo "$count"   # 8
```

Without `declare -i`, you'd use arithmetic expansion:

```bash
count=5
count=$((count + 3))
echo "$count"   # 8
```

### 6.4 Read-Only Constants

```bash
readonly CLUSTER="prod-eks"
declare -r REGION="us-gov-west-1"

CLUSTER="dev-eks"   # ERROR — readonly variable
```

Use constants for config values that must never change mid-script.

### 6.5 Indexed Arrays

Arrays start at index 0.

```bash
namespaces=("abc-api" "jkl-worker" "xyz-db")

echo "${namespaces[0]}"       # abc-api
echo "${namespaces[@]}"       # all elements
echo "${#namespaces[@]}"      # length: 3
echo "${!namespaces[@]}"      # all indices: 0 1 2

namespaces+=("new-service")   # append
```

### 6.6 Associative Arrays

Key-value maps. Requires Bash 4+.

```bash
declare -A regions
regions["prod"]="us-gov-west-1"
regions["dev"]="us-east-2"

echo "${regions[prod]}"       # us-gov-west-1
echo "${!regions[@]}"         # all keys
echo "${regions[@]}"          # all values
```

### 6.7 Environment Variables

Use `export` to make a variable visible to child processes:

```bash
export AWS_PROFILE="govcloud-admin"
export KUBECONFIG="$HOME/.kube/prod-config"
```

Without `export`, the variable only lives in your current shell.

### 6.8 Special / Built-in Variables

| Variable | Meaning |
|---|---|
| `$0` | Script name |
| `$1`, `$2`, ... | Positional arguments |
| `$#` | Number of arguments |
| `$@` | All args as separate words (use quoted: `"$@"`) |
| `$*` | All args as a single word |
| `$?` | Exit code of last command |
| `$$` | Current shell PID |
| `$!` | PID of last backgrounded command |
| `$USER` | Current username |
| `$HOME` | Home directory |
| `$PWD` | Working directory |
| `$RANDOM` | Random integer |
| `$LINENO` | Current line number in the script |

Example — `info.sh`:

```bash
#!/bin/bash
echo "Script: $0"
echo "First arg: $1"
echo "Total args: $#"
echo "Running as: $USER"
```

Run as `./info.sh prod us-east-1`.

### 6.9 Parameter Expansion

Bash has a rich syntax for manipulating variables inline:

```bash
name="deployment.yaml"

echo "${name}"              # deployment.yaml
echo "${name:-default}"     # use 'default' if name is unset/empty
echo "${name:=default}"     # same, but also assign
echo "${#name}"             # length: 15
echo "${name%.yaml}"        # strip .yaml suffix -> deployment
echo "${name#deploy}"       # strip 'deploy' prefix -> ment.yaml
echo "${name/yaml/json}"    # replace first: deployment.json
echo "${name//e/E}"         # replace all: dEploymEnt.yaml
echo "${name:0:5}"          # substring: deplo
```

---

## 7. Quoting Rules

```bash
name="Tia"

echo "Hello $name"    # Hello Tia     (double quotes: expand)
echo 'Hello $name'    # Hello $name   (single quotes: literal)
echo Hello $name      # Hello Tia     (no quotes: risky — word splitting)
```

**Rule of thumb:** always double-quote variables unless you have a specific reason not to. It prevents bugs when values contain spaces.

```bash
file="my report.txt"
rm $file      # tries to delete 'my' AND 'report.txt'
rm "$file"    # correctly deletes 'my report.txt'
```

---

## 8. User Input

```bash
read -p "Enter cluster name: " cluster
echo "You chose: $cluster"

read -s -p "Password: " pw   # -s hides input
echo

read -t 5 -p "Quick! " answer   # -t timeout in seconds
```

---

## 9. Arithmetic

```bash
a=10
b=3

echo $((a + b))    # 13
echo $((a - b))    # 7
echo $((a * b))    # 30
echo $((a / b))    # 3  (integer division)
echo $((a % b))    # 1  (modulo)
echo $((a ** b))   # 1000 (exponent)

# Increment
((a++))
echo "$a"          # 11
```

For floating-point math, Bash alone won't do it — use `bc`:

```bash
echo "scale=2; 10 / 3" | bc    # 3.33
```

---

## 10. Conditionals

### 10.1 if / elif / else

```bash
env="prod"

if [[ "$env" == "prod" ]]; then
  echo "Production deploy"
elif [[ "$env" == "staging" ]]; then
  echo "Staging deploy"
else
  echo "Dev deploy"
fi
```

### 10.2 Test Operators

**String tests:**

| Operator | Meaning |
|---|---|
| `==` or `=` | Equal |
| `!=` | Not equal |
| `-z "$x"` | Empty string |
| `-n "$x"` | Non-empty string |
| `<`, `>` | Lexicographic comparison (inside `[[ ]]`) |

**Integer tests:**

| Operator | Meaning |
|---|---|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-lt` | Less than |
| `-le` | Less than or equal |
| `-gt` | Greater than |
| `-ge` | Greater than or equal |

**File tests:**

| Operator | Meaning |
|---|---|
| `-f path` | Regular file exists |
| `-d path` | Directory exists |
| `-e path` | Path exists (any type) |
| `-r path` | Readable |
| `-w path` | Writable |
| `-x path` | Executable |
| `-s path` | Exists and is non-empty |

**Logical operators inside `[[ ]]`:**

```bash
if [[ -f config.yaml && -r config.yaml ]]; then
  echo "Config exists and is readable"
fi

if [[ "$env" == "prod" || "$env" == "staging" ]]; then
  echo "Non-dev environment"
fi
```

Use `[[ ]]` — not the older `[ ]` — for new scripts. It's safer and supports more features.

### 10.3 case Statements

Cleaner than long `if/elif` chains:

```bash
case "$1" in
  start)
    echo "Starting service"
    ;;
  stop)
    echo "Stopping service"
    ;;
  restart|reload)
    echo "Restarting service"
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac
```

---

## 11. Loops

### 11.1 for Loops

**Classic list form:**

```bash
for ns in abc-api jkl-worker xyz-db; do
  echo "Checking $ns"
done
```

**Over an array:**

```bash
services=("kafka" "elasticsearch" "argocd")
for svc in "${services[@]}"; do
  echo "Restarting $svc"
done
```

**C-style:**

```bash
for ((i=0; i<5; i++)); do
  echo "Iteration $i"
done
```

**Over command output:**

```bash
for pod in $(kubectl get pods -o name); do
  echo "Found $pod"
done
```

### 11.2 while Loops

```bash
count=0
while [[ $count -lt 5 ]]; do
  echo "Attempt $count"
  ((count++))
done
```

**Reading a file line by line:**

```bash
while IFS= read -r line; do
  echo "Line: $line"
done < input.txt
```

### 11.3 until Loops

Runs until the condition becomes true. Great for polling:

```bash
until kubectl get pod my-app | grep -q Running; do
  echo "Waiting for pod..."
  sleep 2
done
```

### 11.4 break and continue

```bash
for i in 1 2 3 4 5; do
  if [[ $i -eq 3 ]]; then continue; fi   # skip 3
  if [[ $i -eq 5 ]]; then break; fi      # stop at 5
  echo "$i"
done
# Output: 1 2 4
```

---

## 12. Functions

```bash
deploy_service() {
  local service="$1"
  local namespace="$2"

  echo "Deploying $service to $namespace"
  kubectl apply -f "$service.yaml" -n "$namespace"

  return $?   # return the exit code of the last command
}

deploy_service "kafka-connect" "abc-streaming"
```

**Key points:**

- Arguments are accessed as `$1`, `$2`, etc. — same as script arguments.
- Always use `local` for variables inside functions to avoid polluting globals.
- Functions return an exit code (0-255), not arbitrary values. To "return" data, use `echo` and capture with command substitution:

```bash
get_namespace_count() {
  kubectl get ns --no-headers | wc -l
}

count=$(get_namespace_count)
echo "There are $count namespaces"
```

---

## 13. Command Substitution

Capture the output of a command into a variable with `$( )`:

```bash
today=$(date +%Y-%m-%d)
current_context=$(kubectl config current-context)
echo "Running on $current_context at $today"
```

You can nest and combine freely:

```bash
backup_file="backup-$(hostname)-$(date +%s).tar.gz"
```

Avoid the older backtick syntax `` `command` `` — `$()` nests better and is clearer.

---

## 14. Exit Codes and Error Handling

Every command returns an exit code: `0` = success, anything else = failure.

```bash
kubectl apply -f deployment.yaml
if [[ $? -ne 0 ]]; then
  echo "Deployment failed" >&2
  exit 1
fi
```

**The magic line every serious script should have:**

```bash
set -euo pipefail
```

- `-e` — exit immediately on any command failure.
- `-u` — treat unset variables as errors.
- `-o pipefail` — a pipeline fails if any command in it fails (not just the last).

Combined with traps (see section 22), this prevents most silent-failure bugs.

**Manually failing:**

```bash
if [[ ! -f config.yaml ]]; then
  echo "Missing config.yaml" >&2
  exit 1
fi
```

---

## 15. Redirection and Pipes

```bash
command > file.log          # overwrite file with stdout
command >> file.log         # append stdout
command 2> errors.log       # redirect stderr
command 2>&1                # merge stderr into stdout
command &> all.log          # redirect both (bash shorthand)
command < input.txt         # feed file as stdin
command1 | command2         # pipe stdout of cmd1 to stdin of cmd2
```

**Real-world example:**

```bash
kubectl get pods -A 2>&1 | grep -v Running | tee /tmp/broken-pods.log
```

`tee` writes to both a file and stdout.

**Discarding output:**

```bash
command > /dev/null 2>&1    # suppress all output
```

---

## 16. Globbing and Wildcards

```bash
ls *.yaml          # all .yaml files
ls deploy-*.yaml   # files starting with 'deploy-'
ls ?.txt           # single-char names: a.txt, b.txt
ls [abc].txt       # a.txt, b.txt, or c.txt
```

**Extended globs** (after `shopt -s extglob`):

```bash
ls !(*.bak)        # everything except .bak files
```

---

## 17. String Manipulation

```bash
s="deployment.yaml"

echo "${#s}"            # 15 (length)
echo "${s^^}"           # DEPLOYMENT.YAML (uppercase)
echo "${s,,}"           # deployment.yaml (lowercase)
echo "${s/yaml/json}"   # deployment.json (replace first)
echo "${s//e/E}"        # dEploymEnt.yaml (replace all)
echo "${s%.yaml}"       # deployment (remove suffix)
echo "${s#deploy}"      # ment.yaml (remove prefix)
echo "${s:0:6}"         # deploy (substring from 0, length 6)
```

**Splitting a string:**

```bash
csv="alice,bob,charlie"
IFS=',' read -ra names <<< "$csv"
for n in "${names[@]}"; do
  echo "$n"
done
```

---

## 18. Arrays in Depth

```bash
arr=("one" "two" "three")

# Length
echo "${#arr[@]}"        # 3

# All elements
echo "${arr[@]}"

# All indices
echo "${!arr[@]}"        # 0 1 2

# Slice
echo "${arr[@]:1:2}"     # two three

# Append
arr+=("four")

# Delete element
unset 'arr[1]'

# Iterate
for item in "${arr[@]}"; do
  echo "$item"
done
```

---

## 19. Working with Files

```bash
# Check existence
[[ -f file.txt ]] && echo "exists"

# Read entire file into a variable
content=$(< file.txt)

# Read file line by line (the safe way)
while IFS= read -r line; do
  echo "Got: $line"
done < file.txt

# Write to a file
echo "log entry" >> app.log

# Create/truncate
> app.log
```

---

## 20. Text Processing Tools

Bash alone is limited — real power comes from composing it with these:

```bash
grep "ERROR" app.log                      # find lines
grep -v "DEBUG" app.log                   # exclude lines
grep -c "WARN" app.log                    # count matches
grep -r "TODO" ./src                      # recursive search

sed 's/foo/bar/g' file.txt                # replace all
sed -i 's/old/new/g' file.txt             # in-place edit

awk '{print $1}' file.txt                 # first column
awk -F',' '{print $2}' file.csv           # CSV, second column

cut -d',' -f2 file.csv                    # similar
sort file.txt | uniq                      # unique lines
wc -l file.txt                            # line count
head -20 file.txt                         # first 20 lines
tail -f app.log                           # follow log live

jq '.items[].metadata.name' pods.json     # parse JSON
```

---

## 21. Process Management

```bash
long_task &                       # run in background
echo "PID: $!"                    # PID of last background job

jobs                              # list background jobs
wait                              # wait for all background jobs
wait $pid                         # wait for specific PID

kill $pid                         # send SIGTERM
kill -9 $pid                      # send SIGKILL

pgrep nginx                       # find PIDs by name
pkill nginx                       # kill by name
```

---

## 22. Traps and Signals

Run cleanup code when a script exits (normally or via signal):

```bash
#!/bin/bash
set -euo pipefail

tempdir=$(mktemp -d)

cleanup() {
  echo "Cleaning up $tempdir"
  rm -rf "$tempdir"
}
trap cleanup EXIT

# ... do work in $tempdir ...
# cleanup runs automatically, even if the script fails
```

Common signals:

- `EXIT` — any exit
- `ERR` — when a command fails (with `set -e`)
- `INT` — Ctrl-C
- `TERM` — `kill` default

---

## 23. Debugging Scripts

```bash
bash -x script.sh           # trace: print each command before running
bash -n script.sh           # syntax check only, don't run
```

Or inside the script:

```bash
set -x    # start tracing
# ... some commands ...
set +x    # stop tracing
```

**ShellCheck** (https://www.shellcheck.net) is a linter that catches most common Bash mistakes. Run it on every script you write — it will teach you more than any tutorial.

---

## 24. Best Practices

1. **Always start with** `set -euo pipefail`.
2. **Always quote variables:** `"$var"` not `$var`.
3. **Use `[[ ]]`**, not `[ ]`.
4. **Use `$( )`**, not backticks.
5. **Use `local`** inside functions.
6. **Use `readonly`** for constants.
7. **Use lowercase** for local/script variables, **UPPERCASE** for environment and constants.
8. **Send errors to stderr:** `echo "error" >&2`.
9. **Validate inputs** at the top of the script.
10. **Use `mktemp`** for temp files, and clean up with `trap`.
11. **Run ShellCheck** on every script.
12. **Keep functions small** and single-purpose.

---

## 25. A Full Realistic Script

A production-style script that ties it all together:

```bash
#!/usr/bin/env bash
#
# pod-health-check.sh - Report non-running pods across critical namespaces.
#
# Usage: ./pod-health-check.sh [--verbose]

set -euo pipefail

# ----- Config -----
readonly NAMESPACES=("abc-api" "jkl-worker" "xyz-db")
readonly LOG_DIR="/tmp/pod-health"
readonly LOG_FILE="${LOG_DIR}/check-$(date +%Y%m%d-%H%M%S).log"
readonly SCRIPT_NAME="$(basename "$0")"

VERBOSE=0

# ----- Helpers -----
log()  { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }
warn() { echo "[$(date +%H:%M:%S)] WARN: $*" | tee -a "$LOG_FILE" >&2; }
die()  { echo "[$(date +%H:%M:%S)] FATAL: $*" >&2; exit 1; }

cleanup() {
  log "Script finished. Log at $LOG_FILE"
}
trap cleanup EXIT

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--verbose]

Checks health of pods in configured namespaces.
EOF
  exit 0
}

# ----- Argument parsing -----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose) VERBOSE=1; shift ;;
    -h|--help) usage ;;
    *) die "Unknown argument: $1" ;;
  esac
done

# ----- Preflight -----
command -v kubectl >/dev/null || die "kubectl not found on PATH"
mkdir -p "$LOG_DIR"

# ----- Functions -----
check_namespace() {
  local ns="$1"
  local bad_count

  if ! kubectl get ns "$ns" >/dev/null 2>&1; then
    warn "Namespace $ns does not exist, skipping"
    return 0
  fi

  bad_count=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null \
    | grep -vE 'Running|Completed' \
    | wc -l)

  if [[ "$bad_count" -gt 0 ]]; then
    warn "$ns: $bad_count unhealthy pod(s)"
    if [[ "$VERBOSE" -eq 1 ]]; then
      kubectl get pods -n "$ns" --no-headers \
        | grep -vE 'Running|Completed' \
        | tee -a "$LOG_FILE"
    fi
  else
    log "$ns: OK"
  fi
}

# ----- Main -----
log "Starting pod health check"
log "Context: $(kubectl config current-context)"

for ns in "${NAMESPACES[@]}"; do
  check_namespace "$ns"
done

log "All checks complete"
```

---

## 26. Cheat Sheet

```bash
# ---- Shebang ----
#!/usr/bin/env bash
set -euo pipefail

# ---- Variables ----
name="value"
declare -i num=5
readonly CONST="fixed"
arr=("a" "b" "c")
declare -A map
export VAR="x"

# ---- Expansion ----
"$var"              # safe quoted
${var:-default}     # default if unset
${#var}             # length
${var%.ext}         # strip suffix
${var/old/new}      # replace first
$(command)          # command output
$((a + b))          # arithmetic

# ---- Conditionals ----
[[ "$x" == "y" ]]
[[ -f /path/to/file ]]
[[ -z "$var" ]]
[[ -n "$var" && -d /tmp ]]

# ---- Loops ----
for x in "${arr[@]}"; do ...; done
for ((i=0; i<10; i++)); do ...; done
while [[ condition ]]; do ...; done
until condition; do ...; done

# ---- Functions ----
my_func() {
  local x="$1"
  echo "$x"
}

# ---- Redirection ----
cmd > out.log
cmd >> out.log
cmd 2>&1
cmd &> all.log
cmd1 | cmd2

# ---- Error handling ----
cmd || die "failed"
trap cleanup EXIT
```

---

## 27. Where to Go Next

Once you're comfortable with everything above, level up with:

- **`jq`** — JSON parsing, essential for working with `kubectl -o json`, AWS CLI, and REST APIs.
- **`yq`** — same idea for YAML (huge for Kubernetes work).
- **`sed` and `awk`** — dedicated text-processing languages.
- **`xargs`** — turning output of one command into arguments for another.
- **`getopts`** — proper command-line argument parsing.
- **`ShellCheck`** — run it on every script, always.
- **The Bash manual** — `man bash` is long but authoritative.
- **Greg's Wiki (BashGuide / BashFAQ / BashPitfalls)** — the best free Bash reference on the internet.

The real learning happens when you start automating things you currently do by hand. Pick a repetitive task from your day — checking pod status, rotating secrets, mirroring a repo, generating an SBOM report — and script it. You'll learn more from one real script than from ten tutorials.
