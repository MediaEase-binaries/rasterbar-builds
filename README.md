# libtorrent-rasterbar Builds

Ce dépôt contient des scripts pour compiler automatiquement la bibliothèque libtorrent-rasterbar et ses bindings Python, puis créer des packages Debian (.deb).

## Scripts disponibles

Ce dépôt contient trois scripts indépendants :

- **build-lib.sh** : Compile uniquement la bibliothèque C++ libtorrent-rasterbar
- **build-bindings.sh** : Compile uniquement les bindings Python
- **build-packages.sh** : Crée les packages Debian à partir des fichiers compilés

Cette séparation permet une meilleure gestion des erreurs, une compilation plus claire et la possibilité de réutiliser les compilations sans re-packager.

## Packages créés

Ces scripts génèrent deux packages :

- **libtorrent-rasterbar** : La bibliothèque C++ complète (contenant à la fois les fichiers binaires et de développement)
- **python3-libtorrent** : Les bindings Python pour libtorrent-rasterbar

## Particularités

- Utilise boost-mediaease (installé dans /tmp/boost) pour la compilation
- Les builds sont automatisés via GitHub Actions
- Basé sur le dépôt [arvidn/libtorrent](https://github.com/arvidn/libtorrent)
- Installe tous les fichiers dans `/usr/local/` pour garantir la compatibilité avec les builds personnalisés
- Inclut la bibliothèque statique (`libtorrent-rasterbar.a`) dans le package libtorrent-rasterbar

## Utilisation

### Processus complet
Pour construire et packager tout en une fois :

```bash
./build-lib.sh <VERSION>
./build-bindings.sh <VERSION>
./build-packages.sh <VERSION>
```

Exemple :
```bash
./build-lib.sh 2.0.9
./build-bindings.sh 2.0.9
./build-packages.sh 2.0.9
```

### Compilation séparée
Il est également possible d'exécuter chaque étape indépendamment :

1. **Compilation de la bibliothèque uniquement :**
```bash
./build-lib.sh 2.0.9
```

2. **Compilation des bindings Python uniquement :**
```bash
./build-bindings.sh 2.0.9
```

3. **Construction des packages uniquement :**
```bash
./build-packages.sh 2.0.9
```

## Structure des packages générés

### libtorrent-rasterbar
- Contient les bibliothèques partagées dans `/usr/local/lib/`
- Inclut les en-têtes dans `/usr/local/include/libtorrent/`
- Contient la bibliothèque statique dans `/usr/local/lib/libtorrent-rasterbar.a`
- Contient les fichiers CMake et pkgconfig pour la compilation d'autres applications

### python3-libtorrent
- Contient les bindings Python dans `/usr/local/lib/python3*/dist-packages/`
- Permet d'utiliser libtorrent depuis Python

## Dépendances

- boost-mediaease (un package .deb est inclus dans le répertoire ./tools)
- build-essential
- libssl-dev
- python3-dev (pour les bindings Python)
- python3-setuptools (pour les bindings Python)
- cmake
- ninja-build

## Structure du projet

- `build-lib.sh` : Script pour compiler libtorrent-rasterbar
- `build-bindings.sh` : Script pour compiler les bindings Python
- `build-packages.sh` : Script pour créer les packages Debian
- `tools/` : Contient le package boost-mediaease nécessaire pour la compilation
- `.github/workflows/` : Configuration des workflows GitHub Actions

## Notes

Le package boost-mediaease est installé dans /tmp/boost et est utilisé uniquement lors de la compilation. Il n'est pas inclus comme dépendance dans les packages .deb finaux.

## Problèmes de compatibilité avec Boost

Les versions 1.2.x de libtorrent-rasterbar ne sont pas compatibles avec les versions récentes de Boost (1.70 et supérieures), car l'API de Boost.Asio a subi des changements importants.

Pour résoudre ce problème, nos scripts détectent automatiquement lorsqu'une version 1.2.x de libtorrent est compilée et utilisent Boost 1.69.0 préinstallé.

### Versions de Boost utilisées

- **Pour libtorrent 1.2.x** : Boost 1.69.0 (package `boost-mediaease_1.69.0-1build1_amd64.deb`) est utilisé
- **Pour libtorrent 2.0.x et supérieur** : Boost 1.88.0 (package `boost-mediaease_1.88.0_rc1-1build1_amd64.deb`) est utilisé

Les packages Boost nécessaires sont disponibles dans le répertoire `tools/` et sont installés automatiquement par les scripts.

### Compilation manuelle

```bash
./build-lib.sh 2.0.9
./build-bindings.sh 2.0.9
./build-packages.sh 2.0.9
```
