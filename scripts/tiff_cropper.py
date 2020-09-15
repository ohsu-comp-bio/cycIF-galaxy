#!/usr/bin/env python3

from tifffile import TiffFile, imsave
import xml.etree.ElementTree as ET
import json
from argparse import ArgumentParser


####
# Script Parameters
#
# Includes paths with source image and destination file name, as well as
# cropping parameters.
####
places = ['TopLeft','TopRight','Center','BottomLeft','BottomRight','Offset']

# Example invocation
# tiff_cropper.py source_image.tiff --location='TopLeft' -x 256 -y 256 
parser = ArgumentParser(description='Crop a multi-dimensional TIFF file in the X and Y dimensions')
parser.add_argument('source',help='Path to source image')
parser.add_argument('--output',default='',help='Path to write the cropped image')
parser.add_argument('--location', choices=places, default='Center', help='Select where to focus the image cropping')
parser.add_argument('-x', type=int, required=True, help='The length along the X axis the image should be cropped to')
parser.add_argument('-y', type=int, required=True, help='The length along the Y axis the image should be cropped to')
parser.add_argument('--x_start', type=int, default=1000, help='Where to begin crop along X axis if "Offset" is the selected crop location')
parser.add_argument('--y_start', type=int, default=1000, help='Where to begin crop along Y axis if "Offset" is the selected crop location')
args = parser.parse_args()

#####
# Set up argument parser and parse arguments
#####

# Use values from parsed args to set script variables
path_to_image = args.source #'/Path/To/some-file.tiff'
if args.output != '':
    path_to_write = source.output #'/Path/To/CROPPED-some-file.tiff'
else:
    path_parts = args.source.split('/')
    path_parts[-1] = 'CROPPED-'+path_parts[-1]
    path_to_write = '/'.join(path_parts)
crop_using = args.location
x_pix = args.x
y_pix = args.y
if crop_using == 'Offset':
    start_x = args.x_start
    start_y = arts.y_start
else:
    start_x = None
    start_y = None

# Set the key values expected within the OME-TIFF metadata for the X and Y
# dimension lengths
size_x_key = 'SizeX'
size_y_key = 'SizeY'



#####
# Read the image and metadata for use as default parameters to functions
#####

# Read the image and get important metadata and the image array
with TiffFile(path_to_image) as tiff:
    ome_md = tiff.ome_metadata
    raw_pix = tiff.asarray()

# Parse the metadata and get the important features 
tree = ET.fromstring(ome_md)



#####
# Utility functions
#####

def get_sizes(image_md):
    # Get the values for the X and Y dims of the image
    size_x = int(list(list(image_md)[1])[-1].get(size_x_key))
    size_y = int(list(list(image_md)[1])[-1].get(size_y_key))
    if size_x == size_y:
        print('Warning: SizeX equal to SizeY - please verify dimensions')
    return size_x, size_y



def etree_to_dict(t):
    """
    Function to convert an XML ElementTree to a python dictionary 
    
    Input
        t: XML Element Tree

    Output
        d: Python dict
    """
    d = {t.tag : list(map(etree_to_dict, list(t)))}
    d.update((k, v) for k, v in t.attrib.items())
    d['text'] = t.text
    return d


def get_new_md(old_md=etree_to_dict(tree)):
    """
    Docstring
    """
    new_md = old_md
    # Modify the X and Y values, crop the image, and write the file
    new_md['{http://www.openmicroscopy.org/Schemas/OME/2016-06}OME'][1]['{http://www.openmicroscopy.org/Schemas/OME/2016-06}Image'][-1][size_x_key] = x_pix
    new_md['{http://www.openmicroscopy.org/Schemas/OME/2016-06}OME'][1]['{http://www.openmicroscopy.org/Schemas/OME/2016-06}Image'][-1][size_y_key] = y_pix
    return new_md



#####
# Core functions
#####

def get_dim_markers(pix_array, md_tree):
    """
    Function which returns a list indicating the relative order of dimensions 
    of interest for the cropping process.

    Currently, the array marks the X-dimension with 'X', the Y-dimension with 
    'Y', and all other dimension with 'I' for "ignore" (meaning they aren't 
    cropped).

    Inputs
        pix_array: Numpy Array (3+ dims)
        md_tree: XML ElementTree

    Output
        which_dims: list of strings
    """
    size_x, size_y = get_sizes(md_tree)
    # Determine which dims correspond X and Y, and create a label array
    found_x = found_y = False
    which_dims = ['' for _ in pix_array.shape]
    for i, dim in enumerate(pix_array.shape):
        if not found_x and dim == size_x:
            which_dims[i] = 'X'
            found_x = True
        elif not found_y and dim == size_y:
            which_dims[i] = 'Y'
            found_y = True
        else:
            which_dims[i] = 'I'

    # If dimensions fail to  match either the X and Y length, then explode
    if not found_x or not found_y:
        raise()
    return which_dims
     

def crop(pix_array, 
         crop_loc=crop_using,
         x_off=start_x,
         y_off=start_y,
         x_start_len=None,
         y_start_len=None,
         x_crop_len=x_pix,
         y_crop_len=y_pix,
         image_md=tree):
    """
    Docstring
    """

    # Establish an X and Y offset based on the cropUsing selection
    if crop_loc == 'Offset':
        offset_x = x_off
        offset_y = y_off
    elif crop_loc == 'TopLeft':
        offset_x = 0
        offset_y = 0
    elif crop_loc == 'TopRight':
        offset_x = x_start_len-x_crop_len
        offset_y = 0
    elif crop_loc == 'BottomLeft':
        offset_x = 0
        offset_y = y_start_len-y_crop_len
    elif crop_loc == 'BottomRight':
        offset_x = x_start_len-x_crop_len
        offset_y = y_start_len-y_crop_len
    elif crop_loc == 'Center':
        offset_x = (x_start_len - x_crop_len)//2
        offset_y = (y_start_len - y_crop_len)//2

    # Get the dimension markers
    which_dims = get_dim_markers(pix_array, image_md)

    # Create the tuple of slices to subset the image array
    slice_tup = ()
    for i, indicator in enumerate(which_dims):
        if indicator == 'I':
            slice_tup = (*slice_tup, slice(0,raw_pix.shape[i]))
        elif indicator == 'X':
            slice_tup = (*slice_tup, slice(offset_x,offset_x+x_pix))
        elif indicator == 'Y':
            slice_tup = (*slice_tup, slice(offset_y,offset_y+y_pix))

    return raw_pix[slice_tup]

   

x_size, y_size = get_sizes(tree)

imsave(path_to_write, crop(raw_pix, x_start_len=x_size, y_start_len=y_size), metadata=get_new_md())
