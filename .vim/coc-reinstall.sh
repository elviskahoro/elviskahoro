#!/usr/bin/bash

set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails

# Install extensions
mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
  echo '{"dependencies":{}}'> package.json
fi
# Change extension names to the extensions you need
npm install coc-git coc-prettier coc-yank coc-sh coc-css coc-html coc-tsserver coc-json coc-texlab coc-markdownlint coc-pyright coc-yaml coc-snippets --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
