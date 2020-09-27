
## Define the program description

## Initiate the parser

import sys
import argparse
from las2xyz import las2xyz


program_desc = 'This script uses laspy and numpy to convert a las into a txt.'


parser = argparse.ArgumentParser(description = program_desc)
parser.add_argument("--input_las", "-i", help="The las to be converted")
parser.add_argument("--output_txt", "-o", help="The txt to be generated")
args = parser.parse_args()

if not (args.input_las) or not (args.output_txt):
    print("Error: missing input las or output txt")
else:
    las2xyz(args.input_las, args.output_txt)
