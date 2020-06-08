#!/bin/bash

srun -A chin_lab --nodes 1 -t 35:00:00 --mem 211G -o Output.txt -e Error.txt java -noverify -Xms200G -Xmx210G -classpath .:FiReTiTiLiB.jar:lib/*:. Cluster &


