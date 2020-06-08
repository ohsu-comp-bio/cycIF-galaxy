#!/bin/bash
#SBATCH --partition=exacloud
#SBATCH --mem=64000
#SBATCH -c 4
#SBATCH -A chin_lab
#SBATCH --time=36:00:00
srun matlab -nodesktop -nosplash -r "registration_py; exit;" $1
