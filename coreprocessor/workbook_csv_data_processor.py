#===================================================================================================#
#title           :workbook_csv_data_processor.py                                                    #
#description     :This script processes the respective sheet to csv                                 #
#author          :Ghantisrikanth                                                                    #
#date            :20200905                                                                          #
#version         :0.8                                                                               #
#usage           :py workbook_csv_data_processor.py -i <<name-of-file-to-process>> -s <<sheet-no>>  #
#notes           :N/A                                                                               #
#python_version  :3.6                                                                               #
#================================================================================================== #



import xlrd
import csv
import argparse
import os

parser = argparse.ArgumentParser(prog='workbook_csv_data_processor.py', description='%(prog)s - Process the workbook to csv')
parser.add_argument("-i", "--input", dest='fname')
parser.add_argument("-s", "--sheet", dest='sname')
args = parser.parse_args()

FNAME = args.fname
SNAME = args.sname

if not FNAME or not SNAME:
    print ("workbook_csv_data_processor.py -i <name/of/workbook> -s <sheet-no: e.g; 0 or 1>")
    exit(1)

def csv_from_excel(excel_file, worksheet_name):
    base = os.path.basename(excel_file)
    print ('INFO: processing started for file: ' + base)
    baseout = os.path.splitext(base)[0]
    workdir = (str('/mnt' + '/data' + '/input'))
    os.chdir(workdir)
    print ('INFO: processsed files will be stored in /mnt/data/output/' + baseout + ' directory')
    workbook = xlrd.open_workbook(excel_file)
    worksheet = workbook.sheet_by_index(int(worksheet_name))
    with open(u'{}.csv'.format(worksheet), 'w') as your_csv_file:
        wr = csv.writer(your_csv_file, quoting=csv.QUOTE_ALL)
        for rownum in range(worksheet.nrows):
            wr.writerow([str(entry) for entry in worksheet.row_values(rownum)])
    outfolder = (str('/mnt/data/output/' + baseout))
    out_folder = os.path.isdir(outfolder)
    if not out_folder:
        print ('INFO: output directory: ' + baseout + ' is not available ' + '\nINFO: Creating the directory')
        os.makedirs(outfolder)
    else:
        print ('INFO: output directory: ' + baseout + ' is available ')
    os.rename('%s' % worksheet +'.csv','/mnt/data/output/' + baseout + '/' + '%s' % worksheet.name + '.csv')
    print('INFO: Saving sheets to the directory')
if __name__ == "__main__":
    csv_from_excel(FNAME, SNAME)

