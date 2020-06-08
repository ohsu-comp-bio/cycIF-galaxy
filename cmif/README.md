# cmIF

Author: engje

Date: 2020-04-13

License: GPLv3

Language: Python3

Description: cmIF is a Python3 library for automated image processing and analysis of multiplex immunofluorescence images


# Example Code

## 1   Import Libraries and Set Paths

Within the directory containing code, cmIF will auto-generate folders for Raw Images (unregistered tiffs),
 QC outputs, Registered Images, Autofluorescence Subtracted Images, and Segmentation outputs. So only 
 `codedir` and `czidir` variables should be modified, retaining the standardized folder structure. 

List the names of the slides to be processed as `ls_sample`. Each slide may have 1 or more scenes acquired during scanning. 

```
# Import libraries
from cmIF import preprocess, mpimage, cmif, process
import os
import sys
import javabridge
import bioformats
import numpy as np
import pandas as pd


# Set Paths
codedir = '/home/groups/graylab_share/Chin_Lab/ChinData/Cyclic_Workflow/cmIF_2019-09-11_NP029'
czidir = '/home/groups/graylab_share/Chin_Lab/ChinData/Cyclic_Images/cmIF_2019-09-11_NP029'
tiffdir = f'{codedir}/RawImages'
qcdir = f'{codedir}/QC'
regdir = f'{codedir}/RegisteredImages'
subdir = f'{codedir}/SubtractedRegisteredImages'
segdir = f'{codedir}/Segmentation'
cropdir = f'{codedir}/Segmentation/Cropped'
preprocess.cmif_mkdir([tiffdir,qcdir,regdir,segdir,subdir,cropdir])

# List slides to be processed
ls_sample = ['HER2B-K174',
 'JE-TMA-35',
 'NP029',
 ]

```

## 2   Export exposure time metadata from .czi

Use separate functions to export exposure time from scans taken with or without scenes.
All images from each slide should be in single subfolders within `czidir`.

```
for s_sample in ls_sample:
    #parse file names
    df_img = cmif.parse_czi(f'{czidir}/{s_sample}',b_scenes=True)
    #no scenes
    #cmif.exposure_times(df_img,codedir,czidir=f'{czidir}/{s_sample}')
    #scenes
    cmif.exposure_times_scenes(df_img, codedir, czidir=f'{czidir}/{s_sample}', s_end='.czi')
```

## 3   QC Raw Images

Export all raw tiffs as 16 bit original images using the microscope software. Put in separate folders,
one per slide, within RawImages folder inside of `codedir`. This section will then generate overviews of all rounds, for QC purposes.

```
preprocess.cmif_mkdir([f'{qcdir}/RawImages'])

for s_sample in ls_sample:
    os.chdir(f'{tiffdir}/{s_sample}')
    #investigate tissues
    df_img = mpimage.parse_org(s_end = "ORG.tif",type='raw')
    cmif.visualize_raw_images(df_img,qcdir,color='c1')
```

## 4   Register Images

This section creates a Matlab script for registration and starts a job on our server (OHSU exacloud).
In this example I crop the NP029  tissue by entering the `new_scene_id : '[upperleftXcoord upperleftYcoord width height]'` as a key:value pair in the `d_register` dictionary of dictionaries. Leaving the dictionary blank will start registration without cropping. Each registered scene goes to a **separate folder**.

```
d_register = {'HER2B-K174':{}, #TMA registration
    'JE-TMA-35':{},
    'NP029':{1:'[0 2000 15000 18000]',2:'[15000 14000 15000 6000]'}, #large registration
 }
ls_order = ['R1','R0','R2','R3','R4','R5','R5Q','R6','R7','R8','R9','R10','R11','R12','R12Q'] 

for key,item in d_register.items():
   #run registration
   cmif.run_registration_matlab(d_register, ls_order, f'{tiffdir}/{key}', f'{regdir}/')
```

## 5   Check Registration

This section will then generate overviews of all rounds of each registered image stack, for QC purposes.

```
cmif.visualize_reg_images(f'{regdir}',qcdir,color='c1')
```

## 6a  Create AF Subtracted Images

Images acquired of background autofluorescence by are scaled by exposure time and subtracted from the respective channel, producing a new image. `d_channel` specifies the name of the background marker to subtract from each channel. `ls_exclude` lists which markers upon which to not perform any AF subtraction (typically c5 images).

Images are output to an AFSubtracted folder within each registered scene's  **separate folder**. The scenes are subsequently combined into a single folder in **6b**. This would be a good point to generate ome-tiff of the full image stack. 
```
#parameters
d_channel = {'c2':'R5Qc2','c3':'R5Qc3','c4':'R5Qc4','c5':'R5Qc5'}
ls_exclude=['DAPI','BMP2', 'CD20', 'CD3', 'CD44', 'CD45', 'CK19',
 'ColI', 'Ecad', 'FoxP3', 'GRNZB', 'LamAC', 'PgR', 'R0c5', 'R12Qc5',]

#subtract
df_img, df_exp,df_markers,df_copy = cmif.autofluorescence_subtract(regdir,codedir,d_channel,ls_exclude)
```

##  6b  Move AF Subtracted Images

Move all scenes from the same slide to **one folder**, for segmentation.

```
for s_sample in ls_sample:
    cmif.move_af_img(s_sample, regdir, subdir, dirtype='tma',b_move=True)
```

##  7   Prep for Segmentation

First, rename filenames that use non-standard marker names.

Then, all inputs are for segmentation are automatically generated, including copying any additional images needed (e.g. DAPI channels), verifying segmentation thresholds, and preparing input files for segmentation (i.e. RoundCyclesTable.txt and Cluster.java specifically for Guillaume Thibault’s segmentation software)

```
#parameters
d_rename = {}
dapi_copy={'-R12_':112}
marker_copy ={} #'CK19':['CK5','CK7'],'CD44':['CD45']
d_segment = {'CK19':1002,'CK5':1002,'CD45':2002,'Ecad':1302,'CD44':3002,'CK7':1002,'CK14':1002}

#cmif.rename_files(d_rename,dir=subdir,b_test=True)
#cmif.copy_files(dir=subdir,dapi_copy=dapi_copy, marker_copy=marker_copy,b_test=False)
#cmif.segmentation_thresholds(subdir,qcdir, d_segment)
cmif.segmentation_inputs(subdir,segdir,d_segment,tma_bool=False,b_start=False, i_counter=5)
```

##  8  Get Dataframe

After segmentation with Guillaume's software, the output is separate feature files for each marker. Here we extract all markers' features from the separate .txt files into single .tsv's; one for the single cell fluorescence intensity (MeanIntensity.tsv) and others for the cell locations (CentroidX.tsv, CentroidY.tsv).

```
for s_sample in ls_sample:
   cmif.extract_dataframe(s_sample, segdir,qcdir)
```

## 9  Filter Data

Post-processing includes filtering out lost cells based on last round DAPI staining and selection of dataframe columns based on desired biomarker sub-cellular location (these are hard coded and linked to the standardized marker names).

```
#parameters
s_dapi = 'DAPI12_Nuclei'
dapi_thresh = 1000
d_channel = {}
ls_exclude=[]

for s_sample in ls_sample:
    cmif.prepare_dataframe(s_sample,s_dapi,dapi_thresh,d_channel,ls_exclude,segdir, codedir)
```

## 10 Fetch Cell Label Files

Gather all cell label (basin) files into one folder, so that they easily can be used for downstream analysis.

```
#paramter
s_sampleset = 'HER2BK174_JETMA35_NP29_31_32_34_35_36_analysis'
s_slide = 'NP029'
es_scene = None  # this will fetch the basin files from any scene form s_slide.
s_ipath = './Segmentation/NP029_Segmentation/'

cmif.fetch_celllabel(s_sampleset, s_slide, s_ipath, s_opath='./', es_scene=es_scene, b_test=True)
```

## 11 Generate Cropped Overlays

Crop smaller regions of images and segmentation basins and create custom overlays for efficient viewing of related markers. 

```
#parameters
#crop 2000,2000 x, y upper corner
d_crop = {'HER2B-K174-Scene-02': (1500,3500),
 'HER2B-K174-Scene-08': (2500,1500),
 'JE-TMA-35-Scene-01': (1500,1500),
 'NP029-Scene-001': (8500,9500),
 'NP031-Scene-002': (2000,8500),
 'NP032-Scene-001': (8500,7000),
 'NP034-Scene-001': (6500,6500),
 'NP035-Scene-001': (800,8500),
 'NP036-Scene-001': (3500,9500)}

tu_dim=(2000,2000)

s_dapi = 'DAPI12_Nuclei'

d_combos = {
        'Stromal':{'PDPN','Vim','CD31','PDGFRa','aSMA','CD44','ColI','ColIV','BMP2'}, 
        'Tumor':{'HER2', 'ER', 'PgR','AR','EGFR','Ecad','CD44','Ki67'},
        'Proliferation':{'Ki67','pHH3','pRB','PCNA'},
        'Immune':{'CD45','CD20','CD68','CD44','PD1', 'CD8', 'CD4','FoxP3','CD3','GRNZB'},
        'Differentiation':{'CK8','CK7','CK19','CK14','CK17','CK5','CD44','Vim'},
        'Nuclear':{'LamB2', 'LamB1', 'LamAC','H3K4','H3K27'},
        'Growth': {'pAKT', 'pS6RP', 'CoxIV', 'pERK', 'Glut1','Ki67'},
        #'Other': { 'gH2AX', 'HIF1a', 'cPARP','53BP1'},
    }

cmif.multipage_tiff(d_combos,d_crop,tu_dim,s_dapi,subdir,b_crop=True)
cmif.crop_basins(d_crop,tu_dim,segdir,cropdir,s_type='Cell')
```

##  Next Steps

Now everything is ready for thresholding using my cmIF Jupyter notebook for visualization.
