# Vim <-> Deckard

Vim connector to Deckard.

# Installation

Install `deckardai/vim-deckard` with your favorite package manager.

## Using [Vundle](https://github.com/gmarik/vundle)

In `.vimrc`

    Bundle 'deckardai/vim-deckard'
  
Then

    :write | source % | BundleInstall

## Using [Pathogen](https://github.com/tpope/vim-pathogen)

  `cd ~/.vim/bundle && git clone git://github.com/deckardai/vim-deckard.git`


This plugin requires Python support, which is commonly included by default. Check with: 

    vim --version | grep python
