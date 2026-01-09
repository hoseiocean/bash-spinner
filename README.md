# Bash Spinner

🌐 **Language:** English | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](#requirements)
[![Tests](https://img.shields.io/badge/Tests-20%20passed-brightgreen.svg)](#testing)

A lightweight, elegant loading spinner for Bash scripts. Provides visual feedback during long-running operations with full macOS and Linux compatibility.

![Bash Spinner Demo](spinner.gif)

---

## Features

- 🎯 **Simple API** — Just `spinner_start` and `spinner_stop`
- 🍎 **macOS Compatible** — Works with Bash 3.2+ (default on macOS)
- 🎨 **Colored Output** — Success (green), failure (red), progress (cyan)
- ⏱️ **Elapsed Time** — Track how long operations take
- 🛡️ **Signal Handling** — Clean interruption with Ctrl+C
- 📟 **TTY Detection** — Graceful fallback in non-interactive environments
- 🔇 **Silent Mode** — Suppress output when needed

---

## Installation

### Option 1: Clone the repository

```bash
git clone https://github.com/hoseiocean/bash-spinner.git
cd bash-spinner
```

### Option 2: Download directly

```bash
curl -O https://raw.githubusercontent.com/hoseiocean/bash-spinner/main/spinner.sh
```

### Option 3: Copy to your project

Simply copy `spinner.sh` to your project directory.

---

## Quick Start

```bash
#!/bin/bash
source spinner.sh

spinner_start "Downloading files"
sleep 3  # Your long-running task here
spinner_stop true "Download complete"
```

Output:
```
⠋ Downloading files
✓ Download complete
```

---

## API Reference

### Functions

| Function | Description | Arguments | Return |
|----------|-------------|-----------|--------|
| `spinner_start` | Starts the spinner | `message` (optional), `delay` (optional) | 0 on success |
| `spinner_stop` | Stops the spinner | `success` (true/false), `message` (optional) | 0 on success |
| `spinner_get_status` | Gets current status | — | "running" or "stopped" |
| `spinner_get_elapsed_time` | Gets elapsed seconds | — | Integer |
| `spinner_force_stop` | Force stops (for interrupt handlers) | — | — |

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SPINNER_SILENT` | `false` | Suppress all output when `true` |

---

## Examples

### Interactive Demo

Run the interactive examples menu:

```bash
./spinner_examples.sh
```

Or run a specific example:

```bash
./spinner_examples.sh 1  # Run example 1
```

---

### Example Descriptions

| # | Name | Purpose | Command |
|---|------|---------|---------|
| 1 | **Simple Usage** | Learn the basic `start`/`stop` workflow with custom duration | `./spinner_examples.sh 1` |
| 2 | **Error Handling** | Show how to display a failure state | `./spinner_examples.sh 2` |
| 3 | **Real Download** | Real-world use case with `curl` and dynamic result | `./spinner_examples.sh 3` |
| 4 | **File Processing** | Display dynamic results (file count) after processing | `./spinner_examples.sh 4` |
| 5 | **Wrapper Function** | Create a reusable function to wrap any command | `./spinner_examples.sh 5` |
| 6 | **Task Loop** | Process multiple sequential tasks in a loop | `./spinner_examples.sh 6` |
| 7 | **Deployment Pipeline** | Simulate a CI/CD pipeline with possible failure | `./spinner_examples.sh 7` |

---

### Comparison: Similar Examples

**Examples 3 and 4 both show dynamic results:**

| Aspect | Example 3: Download | Example 4: File Processing |
|--------|--------------------|-----------------------------|
| **Data source** | Network (curl) | Local filesystem (find) |
| **Result** | Byte count | File count |
| **Failure mode** | Network error | Never fails |

**Examples 5, 6, and 7 all process multiple tasks. Here’s how they differ:**

| Aspect | Example 5: Wrapper | Example 6: Task Loop | Example 7: Pipeline |
|--------|-------------------|---------------------|---------------------|
| **Use case** | Reusable pattern | Simple iteration | Real-world simulation |
| **Error handling** | Per-command exit code | None (all succeed) | Stops on first failure |
| **Reusability** | High (function) | Low (inline code) | Medium (specific flow) |
| **Commands** | Real (`mkdir`, `touch`) | Simulated (`sleep`) | Simulated (`sleep`) |
| **When to use** | DRY principle | Progress feedback | CI/CD scripts |

---

### Code Examples

#### Basic usage

```bash
source spinner.sh

spinner_start "Processing data"
# … your code …
spinner_stop true "Done"
```

#### Error handling

```bash
source spinner.sh

spinner_start "Connecting to server"

if curl -s -o /dev/null "https://example.com"; then
    spinner_stop true "Connected"
else
    spinner_stop false "Connection failed"
fi
```

#### Custom delay

```bash
# Faster animation (default: 0.08)
spinner_start "Quick task" 0.05

# Slower animation
spinner_start "Slow task" 0.15
```

#### Wrapper function (DRY pattern)

```bash
source spinner.sh

run_with_spinner() {
    local description="$1"
    shift
    
    spinner_start "$description"
    sleep 1  # Minimum delay to see spinner
    if "$@" >/dev/null 2>&1; then
        spinner_stop true "$description - OK"
    else
        spinner_stop false "$description - Failed"
        return 1
    fi
}

# Usage
run_with_spinner "Creating directory" mkdir -p /tmp/myapp
run_with_spinner "Downloading config" curl -s -O https://example.com/config
```

#### Task loop

```bash
source spinner.sh

tasks=("Downloading" "Extracting" "Installing" "Configuring")

for task in "${tasks[@]}"; do
    spinner_start "$task"
    sleep 1  # Simulate work
    spinner_stop true "$task complete"
done
```

---

## Requirements

- **Bash** 3.2 or higher
- **Platform**: macOS or Linux
- **Terminal**: Any terminal with ANSI color support

### Tested on

| Platform | Bash Version |
|----------|--------------|
| macOS Tahoe 26.3 | 3.2.57 |
| Ubuntu 24.04 LTS | 5.2.21 |

---

## Testing

Run the test suite:

```bash
./spinner_tests.sh
```

Expected output:
```
=== Tests: Input Validation ===
✓ Test 1: _validate_non_empty: valid string
✓ Test 2: _validate_non_empty: empty string
…

════════════════════════════════════════════════════════════
Test Summary
════════════════════════════════════════════════════════════
Total:  20
Passed: 20
Failed: 0
════════════════════════════════════════════════════════════
All tests passed!
```

---

## Project Structure

```
bash-spinner/
├── spinner.sh           # Main module (source this)
├── spinner_examples.sh  # Interactive examples
├── spinner_tests.sh     # Unit tests
├── README.md
└── LICENSE
```

---

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) principles
4. Add tests for new features
5. Ensure all tests pass (`./spinner_tests.sh`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Use `[[ ]]` for conditionals (Bash-specific)
- Prefix private functions with `_`
- Document functions with comments
- Follow DRY, KISS, YAGNI principles

---

## License

MIT License — see [LICENSE](LICENSE) file.

```
MIT License

Copyright (c) 2025 Thomas Heinis

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
SOFTWARE.
```

---

Made with ♥ by Thomas Heinis
