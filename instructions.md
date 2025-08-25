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
Create a work folder:
```bash 
mkdir -p $PROJECT/cp2k-gpu-build
cd $PROJECT/cp2k-gpu-build
```

Now clone the repo:
```bash
git clone https://github.com/cp2k/cp2k.git
```

## Asking for resources 

In order to compile the code for the GPU, request the necessary resources in an interactive bash shell.

```bash 
srun --partition=dc-gpu-devel --account=jureap141 --gres=gpu:1 --time=02:00:00 --cpus-per-task=8 --mem=64G --pty bash
```
To see the GPU do

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
cd $PROJECT
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
Create the folder

```bash
mkdir -p $PROJECT/libxc-7.0.0-build
cd $PROJECT/libxc-7.0.0-build
cmake $PROJECT/libxc-7.0.0 \
  -DCMAKE_INSTALL_PREFIX=$PROJECT/libxc-7-install \
  -DBUILD_SHARED_LIBS=ON \
  -DENABLE_FORTRAN=ON \
  -DENABLE_XCF03=ON

make -j 8
make install
```
and

```bash
export CMAKE_PREFIX_PATH=$PROJECT/libxc-7-install:$CMAKE_PREFIX_PATH
```
### libxsmm

[libxsmm](https://github.com/libxsmm/libxsmm), to install do:

```bash
# create the install folder 
mkdir -p $PROJECT/libxsmm-install
git clone --branch 1.16.1 https://github.com/libxsmm/libxsmm.git
cd libxsmm
make generator
make STATIC=0
# install 
make FC=$(which gfortran) PREFIX=$PROJECT/libxsmm-install STATIC=0 install
## This create
## $PROJECT/libxsmm-install/lib/
export PKG_CONFIG_PATH="$PROJECT/libxsmm-install/lib:$PKG_CONFIG_PATH"

## To check everything done 
ls $PROJECT/libxsmm-install/lib/
# look for
libxsmm.pc  libxsmmext.pc
## To check the version
pkg-config --modversion libxsmmext
## give us
1.16.1
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
if [ ! -d "$PROJECT/fypp-env" ]; then
  python3 -m venv $PROJECT/fypp-env
  source $PROJECT/fypp-env/bin/activate
  pip install --upgrade pip fypp
else
  source $PROJECT/fypp-env/bin/activate
fi

# Update PATH and PYTHONPATH for fypp
export PATH=$PROJECT/fypp-env/bin:$PATH
export PYTHONPATH=$PROJECT/fypp-env/lib/python3.12/site-packages

# ------------------ Prepare source and build dirs ------------------
cd $PROJECT
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
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTING=OFF \
  -DUSE_MPI=ON \
  -DUSE_OPENMP=ON \
  -DUSE_SMM=libxsmm \
  -DUSE_ACCEL=cuda \
  -DWITH_CUDA_PROFILING=OFF \
  -DWITH_GPU=A100 \
  -DCMAKE_INSTALL_PREFIX=$PROJECT/dbcsr-install \
  -DCMAKE_EXE_LINKER_FLAGS="-L$PROJECT/libxsmm-install/lib -lxsmm -lxsmmf -lxsmmext" \
  -DCMAKE_CXX_FLAGS="-Wno-error=deprecated-declarations"

# we also can add this flags but i didn't
  -DCMAKE_C_FLAGS="-Wno-error" \
  -DCMAKE_CXX_FLAGS="-Wno-error" \
  -DCMAKE_Fortran_FLAGS="-Wno-error"



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

```
set this variables:
```bash
export DBCSR_DIR=$PROJECT/dbcsr-install
export CP2K_SRC=$PROJECT/cp2k
export CP2K_BUILD=$PROJECT/cp2k-gpu-build/build
export CP2K_INSTALL=$PROJECT/cp2k-gpu-install
export FC=$(which mpifort)
export CC=$(which mpicc)
export CXX=$(which mpicxx)
export LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/cp2k-gpu-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/libxc-7-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/dbcsr-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/libxsmm-install/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH="$PROJECT/libxsmm-install/lib:$PKG_CONFIG_PATH"
```
create the folders:

```bash
rm -rf $PROJECT/cp2k-gpu-build/build
mkdir $PROJECT/cp2k-gpu-build/build
cd $PROJECT/cp2k-gpu-build/build
```

activate the fypp-env:

```bash
source $PROJECT/fypp-env/bin/activate
```
run the cmake:
```bash
cmake ../cp2k \
  -DCMAKE_BUILD_TYPE=Release \
  -DCP2K_USE_LIBXC=ON \
  -DCP2K_USE_LIBXSMM=ON \
  -DCP2K_USE_ELPA=ON \
  -DCP2K_USE_SCALAPACK=ON \
  -DCP2K_USE_CUDA=ON \
  -DCP2K_USE_MPI=ON \
  -DCP2K_USE_OPENMP=ON \
  -DCMAKE_INSTALL_PREFIX=$PROJECT/cp2k-gpu-install \
  -DCMAKE_PREFIX_PATH="$PROJECT/libxc-7-install;$PROJECT/dbcsr-install;$PROJECT/libxsmm-install" \
  -DCMAKE_Fortran_COMPILER=$(which mpifort) \
  -DCMAKE_EXE_LINKER_FLAGS="-lxsmm -lmkl_rt"

make -j 8 
make install
```

After running the 'make install' command, you can confirm that the binaries are available by checking:

```bash
ls $PROJECT/cp2k-gpu-install/bin
```
All the executables are here.

## Run an example 

In the folder  **/p/project1/jureap141/cp2k-example** or **$PROJECT/cp2k-example** we can an see the example.

I create a minimal `input.int` example file for cp2k that performs a geometric optimization of water molecule ($H_2 O$) using the functional PBE with pseudopotentials GTH.

in order to do this we need some required files:

- BASIS_MOLOPT: from cp2k/data/BASIS_MOLOPT
- GTH_POTENTIALS: from cp2k/data/GTH_POTENTIALS

that I copy the originals as follows:
```bash
cp $PROJECT/cp2k-gpu-build/cp2k/data/BASIS_MOLOPT .
cp $PROJECT/cp2k-gpu-build/cp2k/data/GTH_POTENTIALS .
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

# Activate fypp environment if needed
source $PROJECT/fypp-env/bin/activate

# Export library paths
export LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/cp2k-gpu-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/libxc-7-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/dbcsr-install/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PROJECT/libxsmm-install/lib:$LD_LIBRARY_PATH

# force the use of GPU
export DBCSR_ACC_LIB=CUDA

# Verification message
echo "Starting CP2K job with GPU support enabled (DBCSR_ACC_LIB=CUDA)"

# GPUs status
echo "GPU status before starting CP2K:"
nvidia-smi

# Set number of OpenMP threads per MPI rank
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

## Run CP2K
## Basic run
#srun $PROJECT/cp2k-gpu-install/bin/cp2k.psmp --version
## The output is in output.out because we use -o output.out
#srun $PROJECT/cp2k-gpu-install/bin/cp2k.psmp -i input.inp -o output.out
## The output is in cp2k.out by slurm
srun $PROJECT/cp2k-gpu-install/bin/cp2k.psmp -i input.inp
```
and run:
```bash
sbatch job.sbatch
```
If you wish, you can create a file called `load_cp2k_env.sh` to load all modules in an interactive bash shell to run some tests and then run `source load_cp2k_env.sh` or put it directly in the `~/.bashrc`.

We now have the cp2k.out file containing all the information.

# JUPITER 

Here you can find some notes of how to use jupiter Slides of the talk by Jens Henrik Göbbert [jupiter-slides](https://www.fz-juelich.de/en/ias/jsc/news/events/training-courses/2023/supercomputing-1/04-jupyterlab) in general this is the course [curse-slides](https://www.fz-juelich.de/en/ias/jsc/education/training-courses/training-materials/course-material-sc-introduction-may-23) and [jupiter](https://gitlab.jsc.fz-juelich.de/jupyter4jsc/prace-2022.04-jupyter4hpc/-/tree/main/).

# Resources

To check the current QOS settings in JURECA, you can use the following command:
```bash
$ squeue --me or squeue -u $USER
$ sacctmgr show qos format=Name,MaxSubmitJobs,MaxJobs,MaxWall,MaxTRESPU%30
$ sacctmgr associations user=$USER format=User,Account,Partition,QOS
jutil user projects -u $USER
jutil user cpuquota -u $USER -p jureap141
jutil user dataquota -u $USER -p jureap141

```

