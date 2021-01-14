# -*- coding: UTF-8 -*- 
import os
import os.path
import shutil
from openpyxl import load_workbook



exportcount = 0

def duqu_gongzuobo(path, name, ext):
	global exportcount
	file_name = '%s/%s%s' % (path, name, ext)
	workbook = load_workbook(file_name, True, False, True, True)
	sheet_names = workbook.get_sheet_names()
	for sheet_name in sheet_names:
		if not sheet_name.startswith('_') and not sheet_name.startswith('Lang'):
			exportcount = exportcount + 1
			#print 'output txt ' , exportcount

def chuli_wenjia(target):
	(path_name, file_name) = os.path.split(target)
	(base_name, ext) = os.path.splitext(file_name)
	if ext == '.xlsx' or ext == '.xlsm':
		duqu_gongzuobo(path_name, base_name, ext)

#获取excel表所有将要导出的文件数量
def getWillExportCount():
	for root, dirs, files in os.walk('./sheet'):
		for each_file in files:
			if not each_file.startswith('~'):
				file_name = '%s/%s' % (root, each_file)
				chuli_wenjia(file_name)
				

#获取目录下边所有proto文件名
def listdirbaseroot(rootPath,countEx):  #传入存储的list
	for file in os.listdir(rootPath):
		if file.endswith("lua") and not file.startswith("Lang"):
			countEx.insert(0,file)
			

def publish():
	if os.path.exists("output"):
		shutil.rmtree("output")
	os.makedirs("output")
	
	os.system("python jiexi_excel_lua.py ./sheet")
	
	# getWillExportCount()
	# configList = []
	# listdirbaseroot("./output",configList)
	# if (exportcount+1) != len(configList):
	# 	print "    ->failed"
	# 	return False
	# else:
	# 	proDatain = "ProData" in os.getcwd()
	# 	toPath = "../../ProSrc/runtime/src/app/WDConfig"
	# 	print proDatain
		
	# 	if proDatain == False:
	# 		toPath = "../ProSrc/runtime/src/app/WDConfig"
			
	# 	if os.path.exists(toPath):
	# 		shutil.rmtree(toPath)
	# 	shutil.copytree("output", toPath)

	print "    ->succeed"
	return True

def run():
	print "  ->publish excel"
	
	ret = True
	startcwd = os.getcwd()
	current_path = os.path.abspath(__file__)
	father_path = os.path.abspath(os.path.dirname(current_path) + os.path.sep + ".")
	os.chdir(father_path)

	ret = publish()
		
	os.chdir(startcwd)
	
	return ret
	
if __name__=='__main__':
	run()
	os.system("pause")