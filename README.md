# cycIF-galaxy

## cmif
A python library written by Jenny Eng for automated image processing and analysis of multiplex immunofluorescence images.

## Galaxy
Galaxy tools wrappers for the cycIF workflow

## Conda
Conda recipes for building packages to be used with galaxy tools (see [ohsu-comp-bio conda channel](https://anaconda.org/ohsu-comp-bio/repo))

## Scripts

This folder contains scripts for converting tiff to ome-tiff and are based on a set of command-line tools [bioformats2raw](https://github.com/glencoesoftware/bioformats2raw) and [raw2ometiff](https://github.com/glencoesoftware/raw2ometiff). See [glencoe docs](https://www.glencoesoftware.com/blog/2019/12/09/converting-whole-slide-images-to-OME-TIFF.html) for more information.

The cycif2ometiff.sh/py scripts were written by Damir Sudar (dsudar_qi@sudar.com). These scripts take a directory of tiffs and create a single tiled/pyramided OME-TIFF incoporating metadata into the OME-XML header.