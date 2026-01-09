# Bash Spinner

🌐 **Langue :** [English](README.md) | Français | [Deutsch](README.de.md) | [Español](README.es.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](#prérequis)
[![Tests](https://img.shields.io/badge/Tests-20%20passed-brightgreen.svg)](#tests)

Un spinner de chargement léger et élégant pour scripts Bash. Fournit un retour visuel pendant les opérations longues, compatible macOS et Linux.

![Bash Spinner Demo](spinner.gif)

---

## Fonctionnalités

- 🎯 **API Simple** — Juste `spinner_start` et `spinner_stop`
- 🍎 **Compatible macOS** — Fonctionne avec Bash 3.2+ (par défaut sur macOS)
- 🎨 **Sortie Colorée** — Succès (vert), échec (rouge), progression (cyan)
- ⏱️ **Temps Écoulé** — Suivez la durée des opérations
- 🛡️ **Gestion des Signaux** — Interruption propre avec Ctrl+C
- 📟 **Détection TTY** — Mode dégradé en environnement non-interactif
- 🔇 **Mode Silencieux** — Supprimez la sortie si nécessaire

---

## Installation

### Option 1 : Cloner le dépôt

```bash
git clone https://github.com/hoseiocean/bash-spinner.git
cd bash-spinner
```

### Option 2 : Téléchargement direct

```bash
curl -O https://raw.githubusercontent.com/hoseiocean/bash-spinner/main/spinner.sh
```

### Option 3 : Copier dans votre projet

Copiez simplement `spinner.sh` dans le répertoire de votre projet.

---

## Démarrage Rapide

```bash
#!/bin/bash
source spinner.sh

spinner_start "Téléchargement des fichiers"
sleep 3  # Votre tâche longue ici
spinner_stop true "Téléchargement terminé"
```

Sortie :
```
⠋ Téléchargement des fichiers
✓ Téléchargement terminé
```

---

## Référence API

### Fonctions

| Fonction | Description | Arguments | Retour |
|----------|-------------|-----------|--------|
| `spinner_start` | Démarre le spinner | `message` (optionnel), `délai` (optionnel) | 0 si succès |
| `spinner_stop` | Arrête le spinner | `succès` (true/false), `message` (optionnel) | 0 si succès |
| `spinner_get_status` | Obtient le statut actuel | — | "running" ou "stopped" |
| `spinner_get_elapsed_time` | Obtient les secondes écoulées | — | Entier |
| `spinner_force_stop` | Arrêt forcé (pour gestionnaires d’interruption) | — | — |

### Configuration

| Variable | Défaut | Description |
|----------|--------|-------------|
| `SPINNER_SILENT` | `false` | Supprime toute sortie si `true` |

---

## Exemples

### Démo Interactive

Lancez le menu d’exemples interactif :

```bash
./spinner_examples.sh
```

Ou lancez un exemple spécifique :

```bash
./spinner_examples.sh 1  # Lance l’exemple 1
```

---

### Description des Exemples

| # | Nom | Objectif | Commande |
|---|-----|----------|----------|
| 1 | **Utilisation Simple** | Apprendre le workflow basique `start`/`stop` avec durée personnalisée | `./spinner_examples.sh 1` |
| 2 | **Gestion d’Erreur** | Montrer comment afficher un état d’échec | `./spinner_examples.sh 2` |
| 3 | **Téléchargement Réel** | Cas d’usage réel avec `curl` et résultat dynamique | `./spinner_examples.sh 3` |
| 4 | **Traitement de Fichiers** | Afficher des résultats dynamiques (nombre de fichiers) après traitement | `./spinner_examples.sh 4` |
| 5 | **Fonction Wrapper** | Créer une fonction réutilisable pour encapsuler toute commande | `./spinner_examples.sh 5` |
| 6 | **Boucle de Tâches** | Traiter plusieurs tâches séquentielles dans une boucle | `./spinner_examples.sh 6` |
| 7 | **Pipeline de Déploiement** | Simuler un pipeline CI/CD avec échec possible | `./spinner_examples.sh 7` |

---

### Comparaison : Exemples Similaires

**Les exemples 3 et 4 montrent tous deux des résultats dynamiques :**

| Aspect | Exemple 3 : Téléchargement | Exemple 4 : Traitement de Fichiers |
|--------|---------------------------|-----------------------------------|
| **Source de données** | Réseau (curl) | Système de fichiers local (find) |
| **Résultat** | Nombre d’octets | Nombre de fichiers |
| **Mode d’échec** | Erreur réseau | N’échoue jamais |

**Les exemples 5, 6 et 7 traitent tous plusieurs tâches. Voici leurs différences :**

| Aspect | Exemple 5 : Wrapper | Exemple 6 : Boucle | Exemple 7 : Pipeline |
|--------|--------------------|--------------------|---------------------|
| **Cas d’usage** | Pattern réutilisable | Itération simple | Simulation réelle |
| **Gestion d’erreur** | Code de sortie par commande | Aucune (tout réussit) | Arrêt au premier échec |
| **Réutilisabilité** | Haute (fonction) | Basse (code inline) | Moyenne (flux spécifique) |
| **Commandes** | Réelles (`mkdir`, `touch`) | Simulées (`sleep`) | Simulées (`sleep`) |
| **Quand utiliser** | Principe DRY | Feedback de progression | Scripts CI/CD |

---

### Exemples de Code

#### Utilisation basique

```bash
source spinner.sh

spinner_start "Traitement des données"
# … votre code …
spinner_stop true "Terminé"
```

#### Gestion d’erreur

```bash
source spinner.sh

spinner_start "Connexion au serveur"

if curl -s -o /dev/null "https://example.com"; then
    spinner_stop true "Connecté"
else
    spinner_stop false "Échec de connexion"
fi
```

#### Délai personnalisé

```bash
# Animation plus rapide (défaut : 0.08)
spinner_start "Tâche rapide" 0.05

# Animation plus lente
spinner_start "Tâche lente" 0.15
```

#### Fonction wrapper (pattern DRY)

```bash
source spinner.sh

run_with_spinner() {
    local description="$1"
    shift
    
    spinner_start "$description"
    sleep 1  # Délai minimum pour voir le spinner
    if "$@" >/dev/null 2>&1; then
        spinner_stop true "$description - OK"
    else
        spinner_stop false "$description - Échec"
        return 1
    fi
}

# Utilisation
run_with_spinner "Création du répertoire" mkdir -p /tmp/myapp
run_with_spinner "Téléchargement config" curl -s -O https://example.com/config
```

#### Boucle de tâches

```bash
source spinner.sh

tasks=("Téléchargement" "Extraction" "Installation" "Configuration")

for task in "${tasks[@]}"; do
    spinner_start "$task"
    sleep 1  # Simule le travail
    spinner_stop true "$task terminé"
done
```

---

## Prérequis

- **Bash** 3.2 ou supérieur
- **Plateforme** : macOS ou Linux
- **Terminal** : Tout terminal supportant les couleurs ANSI

### Testé sur

| Plateforme | Version Bash |
|------------|--------------|
| macOS Tahoe 26.3 | 3.2.57 |
| Ubuntu 24.04 LTS | 5.2.21 |

---

## Tests

Lancez la suite de tests :

```bash
./spinner_tests.sh
```

Sortie attendue :
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

## Structure du Projet

```
bash-spinner/
├── spinner.sh           # Module principal (à sourcer)
├── spinner_examples.sh  # Exemples interactifs
├── spinner_tests.sh     # Tests unitaires
├── README.md
└── LICENSE
```

---

## Contribuer

Les contributions sont les bienvenues ! Veuillez suivre ces directives :

1. Forkez le dépôt
2. Créez une branche feature (`git checkout -b feature/fonctionnalite-geniale`)
3. Suivez les principes [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
4. Ajoutez des tests pour les nouvelles fonctionnalités
5. Assurez-vous que tous les tests passent (`./spinner_tests.sh`)
6. Committez vos changements (`git commit -m 'Ajout fonctionnalité géniale'`)
7. Poussez vers la branche (`git push origin feature/fonctionnalite-geniale`)
8. Ouvrez une Pull Request

### Style de Code

- Utilisez `[[ ]]` pour les conditionnels (spécifique Bash)
- Préfixez les fonctions privées avec `_`
- Documentez les fonctions avec des commentaires
- Suivez les principes DRY, KISS, YAGNI

---

## Licence

Licence MIT — voir le fichier [LICENSE](LICENSE).

---

Fait avec ♥ par Thomas Heinis
