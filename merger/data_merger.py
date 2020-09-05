#=======================================================================================#
#title           :data_merger.py                                                        #
#description     :This script merges all the processed csvs of workbook to combined csv #
#author          :Sneha Mallav                                                          #
#date            :20200905                                                              #
#version         :1.4                                                                   #
#usage           :py data_merger.py -i <<name-of-file-to-process>>                      #
#notes           :N/A                                                                   #
#python_version  :3.6                                                                   #
#=======================================================================================#




import os
import glob
import pandas as pd
import argparse


parser = argparse.ArgumentParser(prog='data_merger.py', description='%(prog)s - Validate the workbook after removing empty rows')
parser.add_argument("-i", "--input", dest='fname')
args = parser.parse_args()

FNAME = args.fname

if not FNAME:
    print ("data_merger.py -i <name/of/workbook>")
    exit(1)
#creating the output folder path and changing directory.
base = os.path.basename(FNAME)
print ('INFO: creating \"combined_csv\" for file: ' + base)
baseout = os.path.splitext(base)[0]
outfolder = (str('/mnt' + '/data' + '/output/' + baseout))
print ('INFO: the target directory to archive is : ' + outfolder)
os.chdir(outfolder)

extension = 'csv'
all_filenames = [i for i in glob.glob('*.{}'.format(extension))]


#combine all files in the list
combined_csv = pd.concat([pd.read_csv(f) for f in all_filenames ])
#export to csv
combined_csv.to_csv( "combined_csv.csv", index=False, encoding='utf-8-sig')
print ('INFO: stored the \"combined_csv.csv\" in directory: ' + outfolder)

