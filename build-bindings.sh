#!/usr/bin/env bash
set -e

# =============================================================================
# build-bindings.sh
#
# Ce script compile uniquement les bindings Python pour libtorrent-rasterbar
# (sans créer de package Debian)
#
# Usage:
# ./build-bindings.sh <VERSION>
# Exemple:
# ./build-bindings.sh 2.0.9
#
# Notes:
# - Nécessite que la bibliothèque libtorrent-rasterbar ait été compilée par build-lib.sh
# - Utilise b2 (Boost.Build) pour compiler les bindings Python
# - Installe dans le répertoire ./custom_build/install-python uniquement
# =============================================================================

usage() {
    echo "Usage: $0 <VERSION>"
    echo "Example: $0 2.0.9"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

# -----------------------------------------------------------------------------
# 0) Paramètres et variables globales
# -----------------------------------------------------------------------------
INPUT_VERSION="$1"                        # Ex: "2.0.9"
LIBTORRENT_VERSION="${INPUT_VERSION}"
BUILD="1build1"
FULL_VERSION="${LIBTORRENT_VERSION}-${BUILD}"

echo "====> Building Python bindings for libtorrent-rasterbar $LIBTORRENT_VERSION (build: $BUILD)"
echo "====> Full version: $FULL_VERSION"

WHEREAMI="$(dirname "$(readlink -f "$0")")"
PREFIX="/usr/local"
BASE_DIR="$PWD/custom_build"
mkdir -p "$BASE_DIR"

# Répertoires d'installation
INSTALL_DIR="$BASE_DIR/install"           # Où la bibliothèque C++ a été installée
INSTALL_DIR_PYTHON="$BASE_DIR/install-python"
mkdir -p "$INSTALL_DIR_PYTHON"

# Nombre de cœurs pour compilation parallèle
CORES=$(nproc)

# Déterminer la version de Python
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_MAJOR=$(python3 -c 'import sys; print(f"{sys.version_info.major}")')
PYTHON_INCLUDE=$(python3 -c 'import sysconfig; print(sysconfig.get_path("include"))')
PYTHON_LIB=$(python3 -c 'import sysconfig; print(sysconfig.get_config_var("LIBDIR"))')
echo "====> Using Python version: $PYTHON_VERSION (major: $PYTHON_MAJOR)"
echo "====> Python include path: $PYTHON_INCLUDE"
echo "====> Python library path: $PYTHON_LIB"

# -----------------------------------------------------------------------------
# 1) Vérifier et installer le package boost-mediaease si nécessaire
# -----------------------------------------------------------------------------
check_boost() {
    echo "====> Checking if boost-mediaease is installed"
    
    if dpkg -l | grep -q "boost-mediaease"; then
        echo "====> boost-mediaease is already installed"
    else
        echo "====> Installing boost-mediaease from tools directory"
        # Chercher le package boost-mediaease dans le répertoire tools
        local BOOST_PACKAGE=$(find "$WHEREAMI/tools" -name "boost-mediaease*.deb" | head -n 1)
        
        if [ -z "$BOOST_PACKAGE" ]; then
            echo "ERROR: boost-mediaease package not found in the tools directory!"
            exit 1
        fi
        
        echo "====> Found boost package: $BOOST_PACKAGE"
        sudo dpkg -i "$BOOST_PACKAGE"
    fi
    
    # Vérifier que le répertoire /tmp/boost existe
    if [ ! -d "/tmp/boost" ]; then
        echo "ERROR: /tmp/boost directory not found, boost-mediaease might not be installed correctly!"
        exit 1
    fi
    
    # Vérifier la présence de b2/bjam
    if [ ! -f "/tmp/boost/bin/b2" ] && [ ! -f "/tmp/boost/bin/bjam" ]; then
        echo "ERROR: b2/bjam not found in /tmp/boost/bin/!"
        echo "The boost-mediaease package might be damaged or incomplete."
        exit 1
    fi
    
    # Configurer les variables d'environnement pour Boost
    export BOOST_ROOT=/tmp/boost
    export PATH=/tmp/boost/bin:$PATH
    
    echo "====> Boost configuration OK"
}

# -----------------------------------------------------------------------------
# 2) Vérifier les prérequis
# -----------------------------------------------------------------------------
check_prereqs() {
    echo "====> Checking prerequisites"
    
    # Vérifier si les fichiers de libtorrent-rasterbar sont présents dans le répertoire d'installation
    if [ ! -f "$INSTALL_DIR$PREFIX/include/libtorrent/torrent_handle.hpp" ] || [ ! -f "$INSTALL_DIR$PREFIX/lib/libtorrent-rasterbar.so" ]; then
        echo "ERROR: libtorrent-rasterbar files not found in $INSTALL_DIR$PREFIX."
        echo "Make sure you have run build-lib.sh first to compile the library."
        exit 1
    fi
        
    echo "====> Prerequisites OK"
}

# -----------------------------------------------------------------------------
# 3) Télécharger les sources libtorrent si nécessaire
# -----------------------------------------------------------------------------
check_sources() {
    echo "====> Checking libtorrent-rasterbar sources for Python bindings"
    
    local SRC_DIR="$BASE_DIR/libtorrent-$LIBTORRENT_VERSION"
    
    # Vérifier si les sources existent déjà
    if [ -d "$SRC_DIR" ]; then
        echo "====> Sources directory already exists, using existing one"
    else
        echo "ERROR: Source directory $SRC_DIR not found."
        echo "Please run build-lib.sh first to download and compile the library."
        exit 1
    fi
    
    cd "$WHEREAMI"
}

# -----------------------------------------------------------------------------
# 4) Compiler les bindings Python
# -----------------------------------------------------------------------------
build_python_bindings() {
    echo "====> Building Python bindings"
    
    local SRC_DIR="$BASE_DIR/libtorrent-$LIBTORRENT_VERSION"
    
    # Créer les répertoires pour les bindings Python
    mkdir -p "$INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages"
    
    # S'assurer que libtorrent-rasterbar est accessible
    export LD_LIBRARY_PATH="$INSTALL_DIR$PREFIX/lib:$LD_LIBRARY_PATH"
    
    # Aller dans le répertoire des bindings Python
    echo "====> Changing to Python bindings directory"
    cd "$SRC_DIR/bindings/python"
    
    # Nettoyer les anciens fichiers de build
    rm -rf build
    
    echo "====> Compiling Python bindings directly with g++"
    
    # Installer les dépendances nécessaires
    echo "====> Installing required dependencies"
    sudo apt-get update
    sudo apt-get install -y python3-dev libboost-python-dev
    
    # Déterminer le nom de la bibliothèque Boost Python
    BOOST_PYTHON_LIB="boost_python$(echo $PYTHON_VERSION | tr -d '.')"
    echo "====> Using Boost Python library: $BOOST_PYTHON_LIB"
    
    # Créer le répertoire de destination
    mkdir -p "$INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages/"
    
    # Compilateur flags
    CXXFLAGS="-std=c++17 -shared -fPIC -O3"
    
    # Inclure les chemins
    INCLUDE_PATHS="-I$INSTALL_DIR$PREFIX/include -I/tmp/boost/include $(python3-config --includes)"
    
    # Chemins des bibliothèques
    LIB_PATHS="-L$INSTALL_DIR$PREFIX/lib -L/tmp/boost/lib -ltorrent-rasterbar -l$BOOST_PYTHON_LIB"
    
    # Trouver tous les fichiers source .cpp
    echo "====> Finding source files"
    SOURCE_FILES=$(find src -name "*.cpp" | xargs echo)
    
    # Compiler tous les fichiers .cpp en un seul module Python
    echo "====> Compiling sources: $SOURCE_FILES"
    g++ $CXXFLAGS $INCLUDE_PATHS $SOURCE_FILES $LIB_PATHS -o "$INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages/libtorrent.so"
    
    # Vérifier si la compilation a réussi
    if [ $? -ne 0 ]; then
        echo "ERROR: Direct compilation failed"
        
        # Essayer avec des options plus simples
        echo "====> Trying simplified compilation with just the main module file"
        
        # Trouver le fichier principal (module.cpp)
        MODULE_FILE="src/module.cpp"
        if [ -f "$MODULE_FILE" ]; then
            echo "====> Compiling main module file: $MODULE_FILE"
            g++ $CXXFLAGS $INCLUDE_PATHS $MODULE_FILE $LIB_PATHS -o "$INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages/libtorrent.so"
            
            if [ $? -ne 0 ]; then
                echo "ERROR: Simplified compilation also failed"
                exit 1
            fi
        else
            echo "ERROR: Could not find main module file"
            exit 1
        fi
    fi
    
    # Vérifier le résultat final
    if [ -f "$INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages/libtorrent.so" ]; then
        echo "====> Python bindings successfully built"
        file "$INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages/libtorrent.so"
    else
        echo "ERROR: Python bindings not found in the expected location"
        exit 1
    fi
    
    cd "$WHEREAMI"
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------
check_boost
check_prereqs
check_sources
build_python_bindings

echo "====> All done! Python bindings have been built."
echo "====> The Python bindings are in $INSTALL_DIR_PYTHON$PREFIX/lib/python$PYTHON_VERSION/dist-packages/libtorrent.so"
echo "====> You can now create packages with build-packages.sh"
exit 0 
