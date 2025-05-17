asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf set -u nodejs latest
cd
mkdir -p my/tasks
cd my
git clone git@github.com:RoyMickos/notes.git
git clone git@github.com:RoyMickos/pomo.git
git clone git@github.com:RoyMickos/jim.git
git clone git@github.com:RoyMickos/ai_rag.git

cd
mkdir -p .tmux/plugins
git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
# needs node
brew install bitwarden-cli
