derekstavis vimfiles

These are my vimfiles. I created them almost from scratch when I started using Vim and adapted them to my needs.

Based on [Jonathan's vimfiles](https://github.com/greenboxal/vimfiles).

#### What's included

* [Bad Wolf (colorscheme)](https://github.com/sjl/badwolf)
* [Molokai (colorscheme, default)](https://github.com/tomasr/molokai)
* [CtrlP](https://github.com/ctrlpvim/ctrlp.vim)
* [vim-objc](https://github.com/b4winckler/vim-objc)
* [airline](https://github.com/bling/vim-airline)
* [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
* [snipmate](https://github.com/msanders/snipmate.vim)
* [tcomment](https://github.com/tomtom/tcomment_vim)
* [Yankstack](https://github.com/maxbrunsfeld/vim-yankstack)
* [ack.vim](https://github.com/mileszs/ack.vim)
* [textobj-user](https://github.com/kana/vim-textobj-user)
* [textobj-rubyblock](https://github.com/nelstrom/vim-textobj-rubyblock)
* [fugitive](https://github.com/tpope/vim-fugitive)
* [unimpaired](https://github.com/tpope/vim-unimpaired)
* [surround](https://github.com/tpope/vim-surround)
* [delimitMate](https://github.com/Raimondi/delimitMate)
* [markdown-folding](https://github.com/nelstrom/vim-markdown-folding)
* [repeat](https://github.com/tpope/vim-repeat)
* [indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
* [javascript](https://github.com/pangloss/vim-javascript)
* [togglelist](https://github.com/milkypostman/vim-togglelist)
* [vim-numbertoggle](https://github.com/jeffkreeftmeijer/vim-numbertoggle)
* [NERDtree](https://github.com/scrooloose/nerdtree)
* [sourcebeautify](https://github.com/michalliu/sourcebeautify.vim)
* [golang](https://github.com/jnwhiteh/vim-golang)
* [jk-jumps](https://github.com/teranex/jk-jumps.vim)
* [dispatch](https://github.com/tpope/vim-dispatch)
* [Sparkup](https://github.com/rstacruz/sparkup)
* [incsearch](https://github.com/haya14busa/incsearch.vim)
* [vim-puppet](https://github.com/rodjek/vim-puppet)
* [vim-ls](https://github.com/gkz/vim-ls)
* [vim-coffee-script](https://github.com/kchmck/vim-coffee-script)
* [dracula-theme](https://github.com/zenorocha/dracula-theme)
* [tern_for_vim](https://github.com/ternjs/tern_for_vim)
* [localvimrc](https://github.com/embear/vim-localvimrc)
* [editorconfig](https://github.com/editorconfig/editorconfig-vim)

#### Installing (step by step)

First, you need to install [Fira Code](https://github.com/tonsky/FiraCode) font for Powerline and common character ligatures.

Go to your home directory:

    cd ~

Clone my vimfiles repo:


    git clone --recursive https://github.com/derekstavis/vimfiles.git

Rename the repo to .vim in your home directory:

    mv vimfiles ~/.vim

Link vimrc and gvimrc to your home directory:

    ln -s ~/.vim/vimrc ~/.vimrc
    ln -s ~/.vim/gvimrc ~/.gvimrc


Open Vim:

	vim

(if you use MacVim):

	mvim

Install bundles by typing

	:PluginInstall

Execute plugin specific installation

	cd ~/.vim
	bash ./install.sh

Restart vim and enjoy! :)

