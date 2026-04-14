#!/usr/bin/env bash

set -e

SESSION_NAME="omniroute"

echo "🔧 Установка NVM..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

echo "📦 Добавление NVM в ~/.bashrc..."

grep -qxF 'export NVM_DIR="$HOME/.nvm"' ~/.bashrc || cat << 'EOF' >> ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

source ~/.bashrc

echo "⬇️ Установка Node.js 22..."
nvm install 22
nvm alias default 22

echo "📌 Проверка версии Node.js:"
node -v

echo "📦 Установка OmniRoute..."
npm install -g omniroute

echo "🔐 Настройка пароля OmniRoute..."

mkdir -p ~/.omniroute
cd ~/.omniroute

if [ ! -f .env ]; then
  touch .env
fi

read -p "Введите пароль для OmniRoute (по умолчанию 123456): " PASSWORD
PASSWORD=${PASSWORD:-123456}

sed -i '/INITIAL_PASSWORD=/d' .env
echo "INITIAL_PASSWORD=$PASSWORD" >> .env

echo "🧰 Проверка tmux..."

# Установка tmux если нет
if ! command -v tmux &> /dev/null; then
  echo "📦 Устанавливаем tmux..."
  sudo apt update
  sudo apt install -y tmux
fi

echo "🚀 Запуск OmniRoute в tmux-сессии..."

# Убиваем старую сессию если есть
tmux has-session -t $SESSION_NAME 2>/dev/null && tmux kill-session -t $SESSION_NAME

# Создаём новую сессию и запускаем omniroute
tmux new-session -d -s $SESSION_NAME "bash -lc 'source ~/.bashrc && omniroute'"

echo "✅ Готово!"
echo ""
echo "📺 Подключиться к сессии:"
echo "tmux attach -t $SESSION_NAME"
echo ""
echo "🛑 Остановить:"
echo "tmux kill-session -t $SESSION_NAME"
