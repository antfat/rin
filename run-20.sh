#!/bin/bash
# -------------------------------
# Скрипт установки CUDA и запуска майнера
# Параметр $1 = уникальный ID для майнера
# Предназначен для Ubuntu 20.04.6 LTS
# -------------------------------

# Проверка аргумента
if [ -z "$1" ]; then
    echo -e "\e[31mИспользование: $0 <ID>\e[0m"
    exit 1
fi
MINER_ID="$1"

# --- Константы ---
CUDA_VERSION="12.8"
CUDA_PKG="cuda-repo-ubuntu2004-${CUDA_VERSION}-local_12.8.0-570.86.10-1_amd64.deb"
CUDA_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/$CUDA_PKG"
CUDA_PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin"
MINER_URL="https://github.com/zuun1989/ccminer-kudaraidee/releases/download/v1.2.3-rin-solo/ccminer"
POOL_URL="stratum+tcp://rinhash.eu.mine.zergpool.com:7148/"
WALLET="bc1qstxffvn68pkwexp4ly99p6kqeyqa8j56tg9ryl"
MINER_DIR="/tmp/miner"

GREEN="\e[32m"
RESET="\e[0m"

# --- Обновление системы и установка зависимостей ---
echo -e "${GREEN}Обновление системы и установка зависимостей...${RESET}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates gnupg curl build-essential cmake \
libcurl4-openssl-dev libssl-dev libjansson-dev libgmp-dev autoconf automake libtool pkg-config git wget

# --- Очистка старых версий CUDA ---
echo -e "${GREEN}Удаление старых версий CUDA...${RESET}"
sudo apt-get -y --purge remove "*cublas*" "cuda*" "nsight*" || true
sudo apt autoremove -y

# --- Установка CUDA ---
echo -e "${GREEN}Загрузка и установка CUDA ${CUDA_VERSION}...${RESET}"
cd /tmp || exit 1
wget -q $CUDA_PIN_URL
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget -q $CUDA_URL
sudo dpkg -i $CUDA_PKG
sudo cp /var/cuda-repo-ubuntu2004-${CUDA_VERSION}-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-$CUDA_VERSION

# --- Настройка переменных среды ---
echo -e "${GREEN}Настройка переменных среды для CUDA...${RESET}"
export PATH=/usr/local/cuda-$CUDA_VERSION/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:$LD_LIBRARY_PATH
echo "export PATH=/usr/local/cuda-$CUDA_VERSION/bin:\$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc

nvcc --version

# --- Установка и запуск майнера ---
echo -e "${GREEN}Установка и запуск майнера...${RESET}"
mkdir -p $MINER_DIR && cd $MINER_DIR
wget -q $MINER_URL -O miner
chmod +x miner

echo -e "${GREEN}Запуск майнера с ID: $MINER_ID${RESET}"
./miner -o $POOL_URL -u $WALLET -p c=RIN,mc=RIN,m=solo,sd=1 -i 9,ID=$MINER_ID