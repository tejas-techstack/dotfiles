#!/usr/bin/env bash
set -e

BASE=$HOME/comet_env
PYTHON_DIR=$BASE/python311
VENV_DIR=$BASE/venv
FLUX_DIR=$BASE/flux

mkdir -p $BASE
cd $BASE

echo "===== Installing Python 3.11 locally ====="

wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz
tar -xzf Python-3.11.9.tgz
cd Python-3.11.9

./configure --prefix=$PYTHON_DIR --enable-optimizations
make -j$(nproc)
make install

echo "===== Creating venv ====="

$PYTHON_DIR/bin/python3.11 -m venv $VENV_DIR
source $VENV_DIR/bin/activate

echo "===== Upgrading pip ====="

pip install --upgrade pip setuptools wheel

echo "===== Installing build tools ====="

pip install ninja cmake packaging

echo "===== Installing PyTorch (CUDA 12.4) ====="

pip install torch==2.6.0 torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/cu124

echo "===== Verifying GPU ====="

python -c "import torch; print('GPU:', torch.cuda.get_device_name(0))"

echo "===== Cloning Flux ====="

cd $BASE
git clone https://github.com/bytedance/flux.git
cd $FLUX_DIR

echo "===== Pulling submodules ====="

git submodule update --init --recursive

echo "===== Building Flux (SM89 for RTX 4070) ====="

export MAX_JOBS=$(nproc)
./build.sh --arch 89 --nvshmem

echo "===== Installing Flux Python bindings ====="

pip install -e . --no-build-isolation

echo ""
echo "===== Setup Complete ====="
echo ""
echo "Activate environment:"
echo "source $VENV_DIR/bin/activate"
echo ""
echo "Run example:"
echo "cd $FLUX_DIR/examples"
echo "bash run_moe.sh"
