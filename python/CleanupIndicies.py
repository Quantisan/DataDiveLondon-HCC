# -*- coding: utf-8 -*-
"""
Created on Sat Jul 27 10:12:18 2013

@author: sergey
"""
import csv;
class CsvCleaner:
    def __init__(self):
        self.__lsoaSet = dict();
        self.__years = [2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];
    
    def readCsv(self,filename,year):
        f = open(filename,'r')
        reader = csv.reader(f,delimiter=',',quotechar='"' );
        for row in reader:
            lsoa = row[2];
            self.__lsoaSet[(year,lsoa)] = row;
        f.close();
        
        
    def readAll(self,workingDir):
        
        for year in self.__years:
            self.readCsv(workingDir+"/pred"+str(year)+".csv",year);
        
    def filterIndicies(self,workingdir,indexFile,outputIndexFile):
        f = open(workingdir + '/' + indexFile,'r');
        fw = open(workingdir + '/' + outputIndexFile,'wb');
        writer = csv.writer(fw);
        writer.writerow(['YEAR','LSOA CODE','LA CODE','LA NAME','GOR CODE','GOR NAME','IMD SCORE','RANK OF IMD SCORE (where 1 is most deprived)','District,LSOA Name','LSOA Code','Aged 0','Aged 1','Aged 2','Aged 3','Aged 4','Aged 5','Aged 6','Aged 7','Aged 8','Aged 9','Aged 10','Aged 11','Aged 12','Aged 13','Aged 14','Aged 15','Aged 16','Aged 17','Aged 18','Aged 19','Aged 20-24','Aged 25-29','Aged 30-34','Aged 35-39','Aged 40-44','Aged 45-49','Aged 50-54','Aged 55-59','Aged 60-64','Aged 65-69','Aged 70-74','Aged 75-79','Aged 80-84','Aged 85+','Total']);

        reader = csv.reader(f,delimiter=',',quotechar='"');
        for row in reader:
            for year in self.__years:
                lsoa = row[0];
                if (year,lsoa) in self.__lsoaSet:
                    
                    outputRow = list();
                    outputRow.extend([year])
                    outputRow.extend(row)
                    outputRow.extend(self.__lsoaSet[(year,lsoa)]);
                    writer.writerow(outputRow);
        f.close();
        fw.close();


csvCleaner = CsvCleaner();
csvCleaner.readAll('/home/sergey/DataKind/data');
csvCleaner.filterIndicies('/home/sergey/DataKind/data','indicies_deprv_2010.csv','hampshire_depr_data.csv');
