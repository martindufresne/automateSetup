#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# inspired by
# https://gist.github.com/codeinthehole/26b37efa67041e1307db
# https://github.com/why-jay/osx-init/blob/master/install.sh
# https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh

defaults write com.apple.finder AppleShowAllFiles YES; # show hidden files
defaults write com.apple.dock persistent-apps -array; # remove icons in Dock
defaults write com.apple.dock tilesize -int 36; # smaller icon sizes in Dock
defaults write com.apple.dock autohide -bool true; # turn Dock auto-hidng on
defaults write com.apple.dock autohide-delay -float 0; # remove Dock show delay
defaults write com.apple.dock autohide-time-modifier -float 0; # remove Dock show delay
defaults write com.apple.dock orientation right; # place Dock on the right side of screen
defaults write NSGlobalDomain AppleShowAllExtensions -bool true; # show all file extensions
killall Dock 2>/dev/null;
killall Finder 2>/dev/null;

# PRECONDITIONS
# 1)
# make sure the file is executable
# chmod +x osx_bootstrap.sh
#
# 2)
# Your password may be necessary for some packages
#
# 3)
# https://docs.brew.sh/Installation#macos-requirements
# xcode-select --install
# (_xcode-select installation_ installs git already, however git will be installed via brew packages as well to install as much as possible the brew way
#  this way you benefit from frequent brew updates)
# 
# 4) don't let the “Operation not permitted” error bite you
# Please make sure you system settings allow the termianl full disk access
# https://osxdaily.com/2018/10/09/fix-operation-not-permitted-terminal-error-macos/

# `set -eu` causes an 'unbound variable' error in case SUDO_USER is not set
SUDO_USER=$(whoami)

# Check for Homebrew, install if not installed
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew upgrade

# find the CLI Tools update
echo "find CLI tools update"
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n') || true
# install it
if [[ ! -z "$PROD" ]]; then
  softwareupdate -i "$PROD" --verbose
fi

echo "install gnu tools and utilities"
# GNU core utilities
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which

# GNU tools
brew install findutils

echo "install java"
# https://github.com/AdoptOpenJDK/homebrew-openjdk
brew tap AdoptOpenJDK/openjdk
brew install --cask adoptopenjdk
brew install --cask adoptopenjdk8
brew install --cask adoptopenjdk11
brew install --cask adoptopenjdk14
brew install --cask adoptopenjdk15

PACKAGES=(
    alfred
    asciinema
    atom
    bash
    ack
    autoconf
    automake
    autojump
    aws-iam-authenticator
    ffmpeg
    fx
    gcc
    gettext
    gifsicle
    git
    graphviz
    gradle
    golang
    gnupg
    hub
    httpie
    hyperkit
    kotlin
    kubernetes-cli
    kubernetes-helm
    maven
    imagemagick
    jq
    jpegoptim
    libjpeg
    libmemcached
    lynx
    make
    markdown
    memcached
    mercurial
    minikube
    netron
    nmap
    npm
    nvm
    netron
    node
    optipng
    pkg-config
    postgresql
    python
    python3
    pypy
    rabbitmq
    ripgrep
    rename
    ssh-copy-id
    tig
    terminal-notifier
    tesseract
    the_silver_searcher
    tmux
    tree
    yamllint
    vim
    watch
    wget
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

CASKS=(
    atom
    android-studio
    chromium
    firefox
    gimp
    google-chrome
    intellij-idea-ce
    keepingyouawake
    miro
    protopie
    rectangle
    slack
    telegram
    thunderbird
    vagrant
    visual-studio-code
    vlc
    zoom
)

echo "Installing cask apps..."
sudo -u $SUDO_USER brew install --cask ${CASKS[@]}

# install docker
#sudo -u $SUDO_USER brew install --cask docker
#or
# https://github.com/abiosoft/colima
#brew install colima

# clone specific Github repository based on repo in gh-repos.txt
# xargs -n1 git clone < gh-repos.txt
# move repository in specific folder
# mv vim-startify/ ./test/

echo "Installing Python packages..."
sudo -u $SUDO_USER pip3 install --upgrade pip
sudo -u $SUDO_USER pip3 install --upgrade setuptools

PYTHON_PACKAGES=(
    ipython
    virtualenv
    virtualenvwrapper
)
sudo -u $SUDO_USER pip3 install ${PYTHON_PACKAGES[@]}

echo "Installing global npm packages..."
sudo -u $SUDO_USER npm install marked -g

echo "Cleaning up"
brew cleanup
echo "Ask the doctor"
brew doctor

echo "OSX bootstrapping done"
