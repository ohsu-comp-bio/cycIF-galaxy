#!/usr/bin/env python3
import os

from aicsimageio.readers.ome_tiff_reader import OmeTiffReader
from aicsimageio.writers import OmeTiffWriter
from argparse import ArgumentParser


####
# Script Parameters
#
# Includes paths with source image and destination file name, as well as
# cropping parameters.
####
places = ['TopLeft', 'TopRight', 'Center', 'BottomLeft', 'BottomRight',
          'Offset']

# Example invocation
# tiff_cropper.py source_image.tiff --location='TopLeft' -x 256 -y 256
parser = ArgumentParser(
    description="Crop a multi-dimensional TIFF file in the X and Y dimensions")
parser.add_argument('--source', help="Path to source image")
parser.add_argument(
    '--output', default='',
    help="Path to write the cropped image")
parser.add_argument(
    '--location', choices=places, default='Center',
    help="Select where to focus the image cropping")
parser.add_argument(
    '-x', type=int, required=True,
    help="The length along the X axis the image should be cropped to")
parser.add_argument(
    '-y', type=int, required=True,
    help="The length along the Y axis the image should be cropped to")
parser.add_argument(
    '--x_offset', type=int, default=0,
    help="Where to begin crop along X axis if 'Offset' is the selected"
         "crop location")
parser.add_argument(
    '--y_offset', type=int, default=0,
    help="Where to begin crop along Y axis if 'Offset' is the selected"
         "crop location")
parser.add_argument(
    '--overwrite_file', type=bool, required=False, default=None,
    help="Flag to overwrite image or pass over image if it already exists. "
         "None: (default) throw IOError if file exists. "
         "True: overwrite existing file if file exists. "
         "False: silently perform no write actions if file exists.")
args = parser.parse_args()

#####
# Set up argument parser and parse arguments
#####

# Use values from parsed args to set script variables
path_to_image = args.source   # '/Path/To/some-file.tiff'
if args.output:
    path_to_write = args.output   # '/Path/To/CROPPED-some-file.tiff'
else:
    basename = os.path.basename(path_to_image)
    new_name = 'CROPPED-' + basename
    path_to_write = os.path.join(os.path.dirname(path_to_image), new_name)
crop_loc = args.location
x_len = args.x
y_len = args.y
overwrite_file = args.overwrite_file

img = OmeTiffReader(path_to_image)
o = img.metadata

size_x = o.image().Pixels.SizeX
size_y = o.image().Pixels.SizeY

# make cropping slice
if crop_loc == 'Offset':
    x_start = args.x_offset
    x_end = x_start + x_len
    y_start = args.y_offset
    y_end = y_start + y_len
elif crop_loc == 'TopLeft':
    x_start = 0
    x_end = x_len
    y_start = 0
    y_end = y_len
elif crop_loc == 'TopRight':
    x_start = -x_len
    x_end = None
    y_start = 0
    y_end = y_len
elif crop_loc == 'BottomLeft':
    x_start = 0
    x_end = x_len
    y_start = -y_len
    y_end = None
elif crop_loc == 'BottomRight':
    x_start = -x_len
    x_end = None
    y_start = -y_len
    y_end = None
else:      # 'Center'
    assert size_x >= x_len
    assert size_x >= y_len
    x_start = (size_x - x_len) // 2
    x_end = (size_x + x_len) // 2
    y_start = (size_y - y_len) // 2
    y_end = (size_y + y_len) // 2

slice_tup = ()

effictive_dims = img.dims[-img.data.ndim: ]
for dim in effictive_dims:
    if dim == 'X':
        slice_tup += (slice(x_start, x_end), )
    elif dim == 'Y':
        slice_tup += (slice(y_start, y_end), )
    else:
        slice_tup += (slice(None), )

# crop image data
new_img_data = img.data[slice_tup]

# modify metadata
for i in range(o.image_count):
    o.image(i).Pixels.set_SizeX(x_len)
    o.image(i).Pixels.set_SizeY(y_len)

# save the cropped image
with OmeTiffWriter(path_to_write, overwrite_file=overwrite_file) as writer:
    writer.save(new_img_data, ome_xml=o, dimension_order=effictive_dims)

# finally close img
img.close()
