# Bash Spinner

🌐 **Sprache:** [English](README.md) | [Français](README.fr.md) | Deutsch | [Español](README.es.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](#anforderungen)
[![Tests](https://img.shields.io/badge/Tests-20%20passed-brightgreen.svg)](#tests)

Ein leichtgewichtiger, eleganter Lade-Spinner für Bash-Skripte. Bietet visuelles Feedback während lang laufender Operationen mit voller macOS- und Linux-Kompatibilität.

![Bash Spinner Demo](spinner.gif)

---

## Funktionen

- 🎯 **Einfache API** — Nur `spinner_start` und `spinner_stop`
- 🍎 **macOS-kompatibel** — Funktioniert mit Bash 3.2+ (Standard auf macOS)
- 🎨 **Farbige Ausgabe** — Erfolg (grün), Fehler (rot), Fortschritt (cyan)
- ⏱️ **Verstrichene Zeit** — Verfolgen Sie die Dauer von Operationen
- 🛡️ **Signal-Handling** — Saubere Unterbrechung mit Ctrl+C
- 📟 **TTY-Erkennung** — Graceful Fallback in nicht-interaktiven Umgebungen
- 🔇 **Stiller Modus** — Ausgabe bei Bedarf unterdrücken

---

## Installation

### Option 1: Repository klonen

```bash
git clone https://github.com/hoseiocean/bash-spinner.git
cd bash-spinner
```

### Option 2: Direkt herunterladen

```bash
curl -O https://raw.githubusercontent.com/hoseiocean/bash-spinner/main/spinner.sh
```

### Option 3: In Ihr Projekt kopieren

Kopieren Sie einfach `spinner.sh` in Ihr Projektverzeichnis.

---

## Schnellstart

```bash
#!/bin/bash
source spinner.sh

spinner_start "Dateien werden heruntergeladen"
sleep 3  # Ihre lang laufende Aufgabe hier
spinner_stop true "Download abgeschlossen"
```

Ausgabe:
```
⠋ Dateien werden heruntergeladen
✓ Download abgeschlossen
```

---

## API-Referenz

### Funktionen

| Funktion | Beschreibung | Argumente | Rückgabe |
|----------|--------------|-----------|----------|
| `spinner_start` | Startet den Spinner | `message` (optional), `delay` (optional) | 0 bei Erfolg |
| `spinner_stop` | Stoppt den Spinner | `success` (true/false), `message` (optional) | 0 bei Erfolg |
| `spinner_get_status` | Gibt aktuellen Status zurück | — | "running" oder "stopped" |
| `spinner_get_elapsed_time` | Gibt verstrichene Sekunden zurück | — | Integer |
| `spinner_force_stop` | Erzwingt Stopp (für Interrupt-Handler) | — | — |

### Konfiguration

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `SPINNER_SILENT` | `false` | Unterdrückt alle Ausgaben wenn `true` |

---

## Beispiele

### Interaktive Demo

Starten Sie das interaktive Beispielmenü:

```bash
./spinner_examples.sh
```

Oder starten Sie ein bestimmtes Beispiel:

```bash
./spinner_examples.sh 1  # Startet Beispiel 1
```

---

### Beispielbeschreibungen

| # | Name | Zweck | Befehl |
|---|------|-------|--------|
| 1 | **Einfache Nutzung** | Den grundlegenden `start`/`stop`-Workflow mit benutzerdefinierter Dauer lernen | `./spinner_examples.sh 1` |
| 2 | **Fehlerbehandlung** | Zeigen, wie ein Fehlerzustand angezeigt wird | `./spinner_examples.sh 2` |
| 3 | **Echter Download** | Realer Anwendungsfall mit `curl` und dynamischem Ergebnis | `./spinner_examples.sh 3` |
| 4 | **Dateiverarbeitung** | Dynamische Ergebnisse (Dateianzahl) nach der Verarbeitung anzeigen | `./spinner_examples.sh 4` |
| 5 | **Wrapper-Funktion** | Eine wiederverwendbare Funktion erstellen, um jeden Befehl zu wrappen | `./spinner_examples.sh 5` |
| 6 | **Aufgabenschleife** | Mehrere sequentielle Aufgaben in einer Schleife verarbeiten | `./spinner_examples.sh 6` |
| 7 | **Deployment-Pipeline** | Eine CI/CD-Pipeline mit möglichem Fehler simulieren | `./spinner_examples.sh 7` |

---

### Vergleich: Ähnliche Beispiele

**Beispiele 3 und 4 zeigen beide dynamische Ergebnisse:**

| Aspekt | Beispiel 3: Download | Beispiel 4: Dateiverarbeitung |
|--------|---------------------|-------------------------------|
| **Datenquelle** | Netzwerk (curl) | Lokales Dateisystem (find) |
| **Ergebnis** | Byte-Anzahl | Datei-Anzahl |
| **Fehlermodus** | Netzwerkfehler | Schlägt nie fehl |

**Beispiele 5, 6 und 7 verarbeiten alle mehrere Aufgaben. So unterscheiden sie sich:**

| Aspekt | Beispiel 5: Wrapper | Beispiel 6: Schleife | Beispiel 7: Pipeline |
|--------|--------------------|--------------------|---------------------|
| **Anwendungsfall** | Wiederverwendbares Pattern | Einfache Iteration | Reale Simulation |
| **Fehlerbehandlung** | Exit-Code pro Befehl | Keine (alles erfolgreich) | Stoppt bei erstem Fehler |
| **Wiederverwendbarkeit** | Hoch (Funktion) | Niedrig (Inline-Code) | Mittel (spezifischer Flow) |
| **Befehle** | Real (`mkdir`, `touch`) | Simuliert (`sleep`) | Simuliert (`sleep`) |
| **Wann verwenden** | DRY-Prinzip | Fortschritts-Feedback | CI/CD-Skripte |

---

### Code-Beispiele

#### Grundlegende Nutzung

```bash
source spinner.sh

spinner_start "Daten werden verarbeitet"
# … Ihr Code …
spinner_stop true "Fertig"
```

#### Fehlerbehandlung

```bash
source spinner.sh

spinner_start "Verbindung zum Server"

if curl -s -o /dev/null "https://example.com"; then
    spinner_stop true "Verbunden"
else
    spinner_stop false "Verbindung fehlgeschlagen"
fi
```

#### Benutzerdefinierte Verzögerung

```bash
# Schnellere Animation (Standard: 0.08)
spinner_start "Schnelle Aufgabe" 0.05

# Langsamere Animation
spinner_start "Langsame Aufgabe" 0.15
```

#### Wrapper-Funktion (DRY-Pattern)

```bash
source spinner.sh

run_with_spinner() {
    local description="$1"
    shift
    
    spinner_start "$description"
    sleep 1  # Minimale Verzögerung um Spinner zu sehen
    if "$@" >/dev/null 2>&1; then
        spinner_stop true "$description - OK"
    else
        spinner_stop false "$description - Fehlgeschlagen"
        return 1
    fi
}

# Nutzung
run_with_spinner "Verzeichnis erstellen" mkdir -p /tmp/myapp
run_with_spinner "Config herunterladen" curl -s -O https://example.com/config
```

#### Aufgabenschleife

```bash
source spinner.sh

tasks=("Herunterladen" "Extrahieren" "Installieren" "Konfigurieren")

for task in "${tasks[@]}"; do
    spinner_start "$task"
    sleep 1  # Arbeit simulieren
    spinner_stop true "$task abgeschlossen"
done
```

---

## Anforderungen

- **Bash** 3.2 oder höher
- **Plattform**: macOS oder Linux
- **Terminal**: Jedes Terminal mit ANSI-Farbunterstützung

### Getestet auf

| Plattform | Bash-Version |
|-----------|--------------|
| macOS Tahoe 26.3 | 3.2.57 |
| Ubuntu 24.04 LTS | 5.2.21 |

---

## Tests

Führen Sie die Test-Suite aus:

```bash
./spinner_tests.sh
```

Erwartete Ausgabe:
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

## Projektstruktur

```
bash-spinner/
├── spinner.sh           # Hauptmodul (zu sourcen)
├── spinner_examples.sh  # Interaktive Beispiele
├── spinner_tests.sh     # Unit-Tests
├── README.md
└── LICENSE
```

---

## Beitragen

Beiträge sind willkommen! Bitte folgen Sie diesen Richtlinien:

1. Forken Sie das Repository
2. Erstellen Sie einen Feature-Branch (`git checkout -b feature/geniales-feature`)
3. Folgen Sie den [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)-Prinzipien
4. Fügen Sie Tests für neue Features hinzu
5. Stellen Sie sicher, dass alle Tests bestehen (`./spinner_tests.sh`)
6. Committen Sie Ihre Änderungen (`git commit -m 'Geniales Feature hinzufügen'`)
7. Pushen Sie zum Branch (`git push origin feature/geniales-feature`)
8. Öffnen Sie einen Pull Request

### Code-Stil

- Verwenden Sie `[[ ]]` für Bedingungen (Bash-spezifisch)
- Präfixieren Sie private Funktionen mit `_`
- Dokumentieren Sie Funktionen mit Kommentaren
- Folgen Sie den DRY-, KISS-, YAGNI-Prinzipien

---

## Lizenz

MIT-Lizenz — siehe [LICENSE](LICENSE)-Datei.

---

Mit ♥ gemacht von Thomas Heinis
