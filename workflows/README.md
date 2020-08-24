## Workflows

### mcmicro\_galaxy\_port

Invoking this workflow requires:
* `markers.csv` found in the NextFlow implementation of mcmicro 
* `typemap.csv` found in the naivestates repo
* A collection containing all of the raw `.ome.tif` files

Notes about execution:
* For some reason, the s3segmenter wrapper like to default to "Interactive Crop" which causes the job to hang. Make sure to switch the Crop method from "Interactive Crop" before running (recommended "No Crop").
