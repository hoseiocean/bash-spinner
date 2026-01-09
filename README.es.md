# Bash Spinner

🌐 **Idioma:** [English](README.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | Español

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](#requisitos)
[![Tests](https://img.shields.io/badge/Tests-20%20passed-brightgreen.svg)](#pruebas)

Un spinner de carga ligero y elegante para scripts Bash. Proporciona retroalimentación visual durante operaciones de larga duración con compatibilidad total para macOS y Linux.

![Bash Spinner Demo](spinner.gif)

---

## Características

- 🎯 **API Simple** — Solo `spinner_start` y `spinner_stop`
- 🍎 **Compatible con macOS** — Funciona con Bash 3.2+ (predeterminado en macOS)
- 🎨 **Salida Colorida** — Éxito (verde), error (rojo), progreso (cian)
- ⏱️ **Tiempo Transcurrido** — Rastrea la duración de las operaciones
- 🛡️ **Manejo de Señales** — Interrupción limpia con Ctrl+C
- 📟 **Detección TTY** — Modo degradado en entornos no interactivos
- 🔇 **Modo Silencioso** — Suprime la salida cuando sea necesario

---

## Instalación

### Opción 1: Clonar el repositorio

```bash
git clone https://github.com/hoseiocean/bash-spinner.git
cd bash-spinner
```

### Opción 2: Descarga directa

```bash
curl -O https://raw.githubusercontent.com/hoseiocean/bash-spinner/main/spinner.sh
```

### Opción 3: Copiar a tu proyecto

Simplemente copia `spinner.sh` al directorio de tu proyecto.

---

## Inicio Rápido

```bash
#!/bin/bash
source spinner.sh

spinner_start "Descargando archivos"
sleep 3  # Tu tarea de larga duración aquí
spinner_stop true "Descarga completada"
```

Salida:
```
⠋ Descargando archivos
✓ Descarga completada
```

---

## Referencia de API

### Funciones

| Función | Descripción | Argumentos | Retorno |
|---------|-------------|------------|---------|
| `spinner_start` | Inicia el spinner | `message` (opcional), `delay` (opcional) | 0 si éxito |
| `spinner_stop` | Detiene el spinner | `success` (true/false), `message` (opcional) | 0 si éxito |
| `spinner_get_status` | Obtiene el estado actual | — | "running" o "stopped" |
| `spinner_get_elapsed_time` | Obtiene segundos transcurridos | — | Entero |
| `spinner_force_stop` | Detención forzada (para manejadores de interrupción) | — | — |

### Configuración

| Variable | Predeterminado | Descripción |
|----------|----------------|-------------|
| `SPINNER_SILENT` | `false` | Suprime toda salida cuando es `true` |

---

## Ejemplos

### Demo Interactiva

Ejecuta el menú de ejemplos interactivo:

```bash
./spinner_examples.sh
```

O ejecuta un ejemplo específico:

```bash
./spinner_examples.sh 1  # Ejecuta el ejemplo 1
```

---

### Descripción de Ejemplos

| # | Nombre | Propósito | Comando |
|---|--------|-----------|---------|
| 1 | **Uso Simple** | Aprender el flujo básico `start`/`stop` con duración personalizada | `./spinner_examples.sh 1` |
| 2 | **Manejo de Errores** | Mostrar cómo visualizar un estado de error | `./spinner_examples.sh 2` |
| 3 | **Descarga Real** | Caso de uso real con `curl` y resultado dinámico | `./spinner_examples.sh 3` |
| 4 | **Procesamiento de Archivos** | Mostrar resultados dinámicos (conteo de archivos) después del procesamiento | `./spinner_examples.sh 4` |
| 5 | **Función Wrapper** | Crear una función reutilizable para envolver cualquier comando | `./spinner_examples.sh 5` |
| 6 | **Bucle de Tareas** | Procesar múltiples tareas secuenciales en un bucle | `./spinner_examples.sh 6` |
| 7 | **Pipeline de Despliegue** | Simular un pipeline CI/CD con posible fallo | `./spinner_examples.sh 7` |

---

### Comparación: Ejemplos Similares

**Los ejemplos 3 y 4 muestran resultados dinámicos:**

| Aspecto | Ejemplo 3: Descarga | Ejemplo 4: Procesamiento de Archivos |
|---------|--------------------|------------------------------------|
| **Fuente de datos** | Red (curl) | Sistema de archivos local (find) |
| **Resultado** | Conteo de bytes | Conteo de archivos |
| **Modo de fallo** | Error de red | Nunca falla |

**Los ejemplos 5, 6 y 7 procesan múltiples tareas. Así es como difieren:**

| Aspecto | Ejemplo 5: Wrapper | Ejemplo 6: Bucle | Ejemplo 7: Pipeline |
|---------|-------------------|-----------------|---------------------|
| **Caso de uso** | Patrón reutilizable | Iteración simple | Simulación real |
| **Manejo de errores** | Código de salida por comando | Ninguno (todo éxito) | Se detiene en primer fallo |
| **Reusabilidad** | Alta (función) | Baja (código inline) | Media (flujo específico) |
| **Comandos** | Reales (`mkdir`, `touch`) | Simulados (`sleep`) | Simulados (`sleep`) |
| **Cuándo usar** | Principio DRY | Feedback de progreso | Scripts CI/CD |

---

### Ejemplos de Código

#### Uso básico

```bash
source spinner.sh

spinner_start "Procesando datos"
# … tu código …
spinner_stop true "Listo"
```

#### Manejo de errores

```bash
source spinner.sh

spinner_start "Conectando al servidor"

if curl -s -o /dev/null "https://example.com"; then
    spinner_stop true "Conectado"
else
    spinner_stop false "Conexión fallida"
fi
```

#### Retraso personalizado

```bash
# Animación más rápida (predeterminado: 0.08)
spinner_start "Tarea rápida" 0.05

# Animación más lenta
spinner_start "Tarea lenta" 0.15
```

#### Función wrapper (patrón DRY)

```bash
source spinner.sh

run_with_spinner() {
    local description="$1"
    shift
    
    spinner_start "$description"
    sleep 1  # Retraso mínimo para ver el spinner
    if "$@" >/dev/null 2>&1; then
        spinner_stop true "$description - OK"
    else
        spinner_stop false "$description - Fallido"
        return 1
    fi
}

# Uso
run_with_spinner "Creando directorio" mkdir -p /tmp/myapp
run_with_spinner "Descargando config" curl -s -O https://example.com/config
```

#### Bucle de tareas

```bash
source spinner.sh

tasks=("Descargando" "Extrayendo" "Instalando" "Configurando")

for task in "${tasks[@]}"; do
    spinner_start "$task"
    sleep 1  # Simular trabajo
    spinner_stop true "$task completado"
done
```

---

## Requisitos

- **Bash** 3.2 o superior
- **Plataforma**: macOS o Linux
- **Terminal**: Cualquier terminal con soporte de colores ANSI

### Probado en

| Plataforma | Versión de Bash |
|------------|-----------------|
| macOS Tahoe 26.3 | 3.2.57 |
| Ubuntu 24.04 LTS | 5.2.21 |

---

## Pruebas

Ejecuta la suite de pruebas:

```bash
./spinner_tests.sh
```

Salida esperada:
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

## Estructura del Proyecto

```
bash-spinner/
├── spinner.sh           # Módulo principal (a importar)
├── spinner_examples.sh  # Ejemplos interactivos
├── spinner_tests.sh     # Pruebas unitarias
├── README.md
└── LICENSE
```

---

## Contribuir

¡Las contribuciones son bienvenidas! Por favor sigue estas pautas:

1. Haz fork del repositorio
2. Crea una rama de característica (`git checkout -b feature/caracteristica-genial`)
3. Sigue los principios de [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
4. Añade pruebas para las nuevas características
5. Asegúrate de que todas las pruebas pasen (`./spinner_tests.sh`)
6. Haz commit de tus cambios (`git commit -m 'Añadir característica genial'`)
7. Haz push a la rama (`git push origin feature/caracteristica-genial`)
8. Abre un Pull Request

### Estilo de Código

- Usa `[[ ]]` para condicionales (específico de Bash)
- Prefija las funciones privadas con `_`
- Documenta las funciones con comentarios
- Sigue los principios DRY, KISS, YAGNI

---

## Licencia

Licencia MIT — ver archivo [LICENSE](LICENSE).

---

Hecho con ♥ por Thomas Heinis
