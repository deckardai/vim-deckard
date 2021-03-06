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

# Usage: `b`, `w`

Stop Vim's cursor at the **beginning of a word**.
Deckard will then refresh its content.

The default Vim way of jumping to the beginning of the current word is `b`. To go to the next word, `w`. But you can navigate in any other way as well.

# Configuration

This plugin triggers refreshes after 200ms of stopping at the start of a word. You can adjust it with this setting in your `.vimrc`:

    set updatetime=200
