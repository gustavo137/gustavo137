# Instructions to compile CP2K code 

The code [CP2K](https://www.cp2k.org/about) and the [git](https://github.com/cp2k/cp2k).

There are two ways we can work:

1. Use jupyter-jsc if you prefer an interactive environment
    In the JUDAC portal you will see a service called jupyter-jsc. If you click there:
    Opens JupyterLab in JUPITER or JURECA (depending on your choice).
    In JupyterLab you can open terminals, notebooks or run compilations directly.

2.  For console work: use Slurm sbatch or srun
    You have access to the computer systems by using the SLURM scheduler. You do not enter the login nodes directly.
    You will create scripts with sbatch or use srun to launch jobs, which run on the compute nodes.

In this case I will use the `console work`.

### ssh connection to jureca 
Follow this documnetation to connect to judac  [judac documentation](https://apps.fz-juelich.de/jsc/hps/judac/access.html) and jureca
[jureca documentation](https://apps.fz-juelich.de/jsc/hps/jureca/index.html).

### jupiter docs 

[jupiter](https://www.fz-juelich.de/en/ias/jsc/jupiter/tech).

# jureca instructions for Console work

Once in the server activate a project doing:

```bash 
jutil env activate -p jureap141
```

## Dowload cp2k

To use git load the module:

```bash
module load git/
```

Now clone the repo:
```bash
git clone https://github.com/cp2k/cp2k.git
```

## Asking for resources 

In order to compile the code for the GPU, request the necessary resources in an interactive bash shell:
```bash 
srun --partition=dc-gpu-devel --account=jureap141 --gres=gpu:1 --time=02:00:00 --cpus-per-task=8 --mem=64G --pty bash
export COMPILE_DIR=$PROJECT/huet1/CP2K_compil
```

Create a work folder:
```bash 
mkdir -p $COMPILE_DIR/cp2k-gpu-build
cd $COMPILE_DIR/cp2k-gpu-build
```

To see the GPU do:
```bash
echo "we are in GPU: $(hostname)"
```
## Prerequisites

In order to compile the code in JURECA, we need to install specific software such as `FYPP` from Python, [libxc-7.0.0](https://gitlab.com/libxc/libxc/-/releases/7.0.0) and [dbcrs](https://github.com/cp2k/dbcsr?tab=readme-ov-file). You can follow the installation instructions for dbcrs [here](https://cp2k.github.io/dbcsr/develop/page/2-user-guide/1-installation/index.html).

### Create and Activate Python Environment with Fypp

Remember to load the Python module to create the environment:

```bash
module load Python/3.12.3
```
the create the env by doing:

```bash
cd $COMPILE_DIR
python3 -m venv fypp-env
source fypp-env/bin/activate
pip install --upgrade pip
pip install fypp
```

### Build and Install libxc 7.0.0

Follow this:
```bash
#Clone libxc (we'll use version 7.0.0)
curl -LO https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.gz
# or with wget
wget https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.gz

tar -xzf libxc-7.0.0.tar.gz
cd libxc-7.0.0
```

load cmake:
```bash
module load CMake/3.30.3
```

Create the folder and do the installation:
```bash
mkdir -p $COMPILE_DIR/libxc-7.0.0-build
cd $COMPILE_DIR/libxc-7.0.0-build
cmake $COMPILE_DIR/libxc-7.0.0 \
  -DCMAKE_INSTALL_PREFIX=$COMPILE_DIR/libxc-7-install \
  -DBUILD_SHARED_LIBS=ON \
  -DENABLE_FORTRAN=ON \
  -DENABLE_XCF03=ON

make -j 8
make install
```
and

```bash
export CMAKE_PREFIX_PATH=$COMPILE_DIR/libxc-7-install:$CMAKE_PREFIX_PATH
```
### libxsmm

[libxsmm](https://github.com/libxsmm/libxsmm), to install do:

```bash
# create the install folder 
mkdir -p $COMPILE_DIR/libxsmm-install
git clone --branch 1.16.1 https://github.com/libxsmm/libxsmm.git
cd libxsmm
make generator
make STATIC=0
# install 
make FC=$(which gfortran) PREFIX=$COMPILE_DIR/libxsmm-install STATIC=0 install
## This create
## $COMPILE_DIR/libxsmm-install/lib/
export PKG_CONFIG_PATH="$COMPILE_DIR/libxsmm-install/lib:$PKG_CONFIG_PATH"

## To check everything done 
ls $COMPILE_DIR/libxsmm-install/lib/
# look for: libxsmm.pc and  libxsmmext.pc

## To check the version
pkg-config --modversion libxsmmext
## give us : 1.16.1
```

### DBCSR 
[dbcsr](https://github.com/cp2k/dbcsr?tab=readme-ov-file), [dbcsr-intall](https://cp2k.github.io/dbcsr/develop/page/2-user-guide/1-installation/index.html):
You can add the following instructions to a `build_dbcsr.sh` to run everything by doing `bash build_dbcsr.sh` or `source ...` alternatively you can perform the steps individually to have more control:

```bash
#!/bin/bash
set -e  # Exit on error

# ------------------ Load modules ------------------
# 
module purge
module load Stages/2025
module load GCC/13.3.0
module load CMake/3.30.3
module load OpenMPI/5.0.5
module load CUDA/12
module load OpenBLAS/
module load Python/3.12.3  # Needed for fypp
module load git/

# ------------------ Setup Python env for fypp ------------------
if [ ! -d "$COMPILE_DIR/fypp-env" ]; then
  python3 -m venv $COMPILE_DIR/fypp-env
  source $COMPILE_DIR/fypp-env/bin/activate
  pip install --upgrade pip fypp
else
  source $COMPILE_DIR/fypp-env/bin/activate
fi

# Update PATH and PYTHONPATH for fypp
export PATH=$COMPILE_DIR/fypp-env/bin:$PATH
export PYTHONPATH=$COMPILE_DIR/fypp-env/lib/python3.12/site-packages

# ------------------ Prepare source and build dirs ------------------
cd $COMPILE_DIR
if [ -d "dbcsr" ]; then
  rm -rf dbcsr
fi
git clone --recursive https://github.com/cp2k/dbcsr.git
mkdir -p dbcsr/build
cd dbcsr/build

# ------------------ Configure and build ------------------
export CUDA_HOME=/p/software/default/stages/2025/software/CUDA/12
export CUDACXX=$CUDA_HOME/bin/nvcc

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_Fortran_COMPILER=$FC \
  -DCMAKE_CUDA_COMPILER=$NVCC \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTING=OFF \
  -DUSE_MPI=ON \
  -DUSE_OPENMP=ON \
  -DUSE_SMM=libxsmm \
  -DWITH_CUDA_PROFILING=ON \
  -DUSE_ACCEL=cuda \
  -DWITH_GPU=A100 \
  -DCMAKE_INSTALL_PREFIX=$COMPILE_DIR/dbcsr-install \
  -DCMAKE_EXE_LINKER_FLAGS="-L$COMPILE_DIR/libxsmm-install/lib -lxsmm -lxsmmf -lxsmmext" \
  -DCMAKE_CXX_FLAGS="-Wno-error=deprecated-declarations"
```

```bash
# we also can add this flags but i didn't
  -DCMAKE_C_FLAGS="-Wno-error" \
  -DCMAKE_CXX_FLAGS="-Wno-error" \
  -DCMAKE_Fortran_FLAGS="-Wno-error"
```

```bash
make -j 8
make install
```

## libint installation:

```bash
module purge
module load Stages/2025
module load GCC/13.3.0
module load CUDA/12
module load OpenMPI/5.0.5
module load OpenBLAS/
module load imkl/2024.2.0
module load libxc/6.2.2
module load FFTW.MPI/3.3.10
module load ScaLAPACK/2.2.0-fb
module load ELPA/2024.05.001
module load libxsmm/1.17
module load UCX-settings/RC-CUDA
module load MPI-settings/CUDA
module load Python/3.12.3
module load CMake/3.30.3
module load PLUMED/2.9.2
module load GSL/2.8

export COMPILE_DIR=/p/project1/jureap141/huet1/CP2K_compil

export DBCSR_DIR=$COMPILE_DIR/dbcsr-install
export CP2K_SRC=$COMPILE_DIR/cp2k
export CP2K_BUILD=$COMPILE_DIR/cp2k-gpu-build/build
export CP2K_INSTALL=$COMPILE_DIR/cp2k-gpu-install
export FC=$(which mpifort)
export CC=$(which mpicc)
export CXX=$(which mpicxx)
export LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/cp2k-gpu-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libxc-7-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/dbcsr-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libxsmm-install/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH="$COMPILE_DIR/libxsmm-install/lib:$PKG_CONFIG_PATH"

cd $COMPILE_DIR
if [ -d "libint2" ]; then
  rm -rf libint2
fi
cd $COMPILE_DIR/libint2

curl https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-5.tgz
tar -zxf libint-v2.6.0-cp2k-lmax-5.tgz
mv libint-v2.6.0-cp2k-lmax-5/* .
rm -r libint-v2.6.0-cp2k-lmax-5

mkdir -p $COMPILE_DIR/libint2-install

export CXXFLAGS="-fPIC"
./configure --prefix=$COMPILE_DIR/libint2-install \
            --enable-fortran
make -j 8
make install
```


## CP2K installation:

Load the followingf modules:

```bash
module purge
module load Stages/2025
module load GCC/13.3.0
module load CUDA/12
module load OpenMPI/5.0.5
module load OpenBLAS/
module load imkl/2024.2.0
module load libxc/6.2.2
module load FFTW.MPI/3.3.10
module load ScaLAPACK/2.2.0-fb
module load ELPA/2024.05.001
module load libxsmm/1.17
module load UCX-settings/RC-CUDA
module load MPI-settings/CUDA
module load Python/3.12.3
module load CMake/3.30.3
module load PLUMED/2.9.2
module load GSL/2.8


```
set this variables:
```bash
export COMPILE_DIR=/p/project1/jureap141/huet1/CP2K_compil
export DBCSR_DIR=$COMPILE_DIR/dbcsr-install
export CP2K_SRC=$COMPILE_DIR/cp2k
export CP2K_BUILD=$COMPILE_DIR/cp2k-gpu-build/build
export CP2K_INSTALL=$COMPILE_DIR/cp2k-gpu-install
export FC=$(which mpifort)
export CC=$(which mpicc)
export CXX=$(which mpicxx)
export LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/cp2k-gpu-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libxc-7-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/dbcsr-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libxsmm-install/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/p/software/default/stages/2025/software/ELPA/2024.05.001-foss-2024a/lib64:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH="$COMPILE_DIR/libxsmm-install/lib:$PKG_CONFIG_PATH"
```
create the folders:

```bash
rm -rf $COMPILE_DIR/cp2k-gpu-build/build
mkdir -p $COMPILE_DIR/cp2k-gpu-build/build
cd $COMPILE_DIR/cp2k-gpu-build/build
```

activate the fypp-env:

```bash
source $COMPILE_DIR/fypp-env/bin/activate
```
run the cmake:
```bash
cmake ../../cp2k \
  -DCMAKE_BUILD_TYPE=Release \
  -DCP2K_USE_LIBXC=ON \
  -DCP2K_USE_LIBXSMM=ON \
  -DCP2K_USE_CUDA=ON \
  -DCP2K_USE_MPI=ON \
  -DCP2K_USE_ACCEL=CUDA \
  -DCP2K_WITH_GPU=A100 \
  -DCP2K_USE_OPENMP=ON \
  -DCP2K_USE_LIBINT2=ON \
  -DCP2K_USE_PLUMED=ON \
  -DCP2K_USE_ELPA=OFF \
  -DLIBINT2_ROOT=$COMPILE_DIR/libint2-install \
  -DCP2K_SCALAPACK_VENDOR=MKL \
  -DCMAKE_INSTALL_PREFIX=$COMPILE_DIR/cp2k-gpu-install \
  -DCMAKE_PREFIX_PATH="$COMPILE_DIR/libxc-7-install;$COMPILE_DIR/dbcsr-install;$COMPILE_DIR/libxsmm-install;$COMPILE_DIR/libint2-install" \
  -DCMAKE_Fortran_COMPILER=$(which mpifort) \
  -DCMAKE_EXE_LINKER_FLAGS="-lxsmm -lmkl_rt"

make -j 8 
make install
```

After running the 'make install' command, you can confirm that the binaries are available by checking:

```bash
ls $COMPILE_DIR/cp2k-gpu-install/bin
```
All the executables are here.

## Run an example 

In the folder  **/p/project1/jureap141/cp2k-example** or **$COMPILE_DIR/cp2k-example** we can an see the example.

I create a minimal `input.int` example file for cp2k that performs a geometric optimization of water molecule ($H_2 O$) using the functional PBE with pseudopotentials GTH.

in order to do this we need some required files:

- BASIS_MOLOPT: from cp2k/data/BASIS_MOLOPT
- GTH_POTENTIALS: from cp2k/data/GTH_POTENTIALS

that I copy the originals as follows:
```bash
cp $COMPILE_DIR/cp2k-gpu-build/cp2k/data/BASIS_MOLOPT .
cp $COMPILE_DIR/cp2k-gpu-build/cp2k/data/GTH_POTENTIALS .
```
now we use the following `sbatch`:

```bash
#!/bin/bash
#SBATCH --job-name=test2-gpu
#SBATCH --account=jureap141
#SBATCH --partition=dc-gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:4
#SBATCH --time=00:30:00
#SBATCH --mem=64G
#SBATCH --output=cp2kv2.out
#SBATCH --error=cp2kv2.err

# Load required modules
module purge
module load Stages/2025
module load GCC/13.3.0
#module load CMake/3.30.3
module load CUDA/12
module load OpenMPI/5.0.5
module load imkl/2024.2.0
module load libxc/6.2.2
module load FFTW.MPI/3.3.10
module load ScaLAPACK/2.2.0-fb
module load ELPA/2024.05.001
module load libxsmm/1.17
module load UCX-settings/RC-CUDA
module load MPI-settings/CUDA
module load Python/3.12.3
module load PLUMED/2.9.2
module load GSL/2.8


# Activate fypp environment if needed
source $COMPILE_DIR/fypp-env/bin/activate

# Export library paths
export COMPILE_DIR=/p/project1/jureap141/huet1/CP2K_compil
export LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/cp2k-gpu-install/lib64::$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libxc-7-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/dbcsr-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libxsmm-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$COMPILE_DIR/libint2-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/p/software/default/stages/2025/software/PLUMED/2.9.2-foss-2024a/lib64:$LD_LIBRARY_PATH
# force the use of GPU
#srun $COMPILE_DIR/cp2k-gpu-install/bin/cp2k.psmp --version
## The output is in output.out because we use -o output.out
#srun $COMPILE_DIR/cp2k-gpu-install/bin/cp2k.psmp -i input.inp -o output.out
## The output is in cp2k.out by slurm
srun $COMPILE_DIR/cp2k-gpu-install/bin/cp2k.psmp -i input.inp
```
and run:
```bash
sbatch job.sbatch
```
If you wish, you can create a file called `load_cp2k_env.sh` to load all modules in an interactive bash shell to run some tests and then run `source load_cp2k_env.sh` or put it directly in the `~/.bashrc`.

We now have the cp2k.out file containing all the information.

# JUPITER 

Here you can find some notes of how to use jupiter Slides of the talk by Jens Henrik Göbbert [jupiter-slides](https://www.fz-juelich.de/en/ias/jsc/news/events/training-courses/2023/supercomputing-1/04-jupyterlab) in general this is the course [curse-slides](https://www.fz-juelich.de/en/ias/jsc/education/training-courses/training-materials/course-material-sc-introduction-may-23) and [jupiter](https://gitlab.jsc.fz-juelich.de/jupyter4jsc/prace-2022.04-jupyter4hpc/-/tree/main/).