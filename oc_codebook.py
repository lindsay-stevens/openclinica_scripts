from lxml import etree
import csv, argparse

"""parse the provided xml file name"""
parser = argparse.ArgumentParser()
parser.add_argument("-f","--filename", help="OpenClinica ODM 1.3 xml file")
args = parser.parse_args()

"""setup namespace globals, read in xml file"""
ns_odm = {'odm':'http://www.cdisc.org/ns/odm/v1.3'}
ns_oc = {'OpenClinica':'http://www.openclinica.org/ns/odm_ext_v130/v3.1'}
ns_all = dict(ns_odm.items() + ns_oc.items())
tree = etree.parse(args.filename)

"""get the study name and date for the output csv file name"""
study_name_parse = tree.xpath('/odm:ODM/odm:Study[1]/odm:GlobalVariables/'
						'odm:StudyName/text()',namespaces=ns_all)
study_name = ''.join(study_name_parse).lower()
xml_date_parse = tree.xpath('@CreationDateTime',namespaces=ns_all)
xml_date_str = ''.join(xml_date_parse)
xml_date = xml_date_str.partition('T')[0]
csv_file_name = xml_date + ' ' + study_name + ' codebook.csv' 

"""parse ItemDef info"""
item_def_parse = tree.xpath('//odm:ItemDef', namespaces=ns_all)
item_def_list = []
for item_def in item_def_parse:
	item_def_iter_dict = {
		'item_oid': ''.join(item_def.xpath('./@OID')),
		'item_name': ''.join(item_def.xpath('./@Name')),
		'item_data_type': ''.join(item_def.xpath('./@DataType')),
		'item_form_oids': ''.join(item_def.xpath('./@OpenClinica:FormOIDs',
			namespaces=ns_all)),
		'item_code_list': ''.join(item_def.xpath(
			'./odm:CodeListRef/@CodeListOID',namespaces=ns_all))
		}
	item_def_list.append(item_def_iter_dict)

"""parse CodeList info"""
code_list_parse = tree.xpath('//odm:CodeList', namespaces=ns_all)
code_list_list = []
for code_list in code_list_parse:
	code_list_item_parse = code_list.xpath('./odm:CodeListItem'
		,namespaces=ns_all)
	code_list_item_list = []
	code_list_item_dict = {}
	for code_list_item in code_list_item_parse:
		code_list_item_cval = ''.join(code_list_item.xpath(
			'./@CodedValue',namespaces=ns_all))
		code_list_item_ttext = ''.join(code_list_item.xpath(
			'./odm:Decode/odm:TranslatedText/text()', namespaces=ns_all))
		code_list_item_dict = {
			'code_list_item_cval': code_list_item_cval,
			'code_list_item_ttext': code_list_item_ttext
			}
		code_list_item_list.append(code_list_item_dict)
	code_list_iter_dict = {
		'code_list_oid': ''.join(code_list.xpath('./@OID')),
		'code_list_sas': ''.join(code_list.xpath('./@SASFormatName')),
		'code_list_items': code_list_item_list
		}
	code_list_list.append(code_list_iter_dict)

"""join the ItemDef info to the CodeList info on the code_list_oid"""
item_defs_code_lists = []
for item_def in item_def_list:
	if item_def.get('item_code_list') == '':
		item_defs_code_lists.append(item_def)
	else:
		for code_list in code_list_list:
			if (item_def.get('item_code_list') == 
					code_list.get('code_list_oid')):
				item_defs_code_lists.append(
					dict(item_def.items() + code_list.items()))

"""for each code list item write the code and item info to csv outfile"""
item_headers = [
	'item_oid',
	'item_name',
	'item_data_type',
	'item_form_oids',
	'code_list_sas',
	'code_list_item_cval',
	'code_list_item_ttext'
	]
cout = csv.writer(open(csv_file_name,'wb'))
cout.writerow(item_headers)
for item_def_code_list in item_defs_code_lists:
	if 'code_list_items' not in item_def_code_list:
		cout.writerow([
		item_def_code_list['item_oid'],
		item_def_code_list['item_name'],
		item_def_code_list['item_data_type'],
		item_def_code_list['item_form_oids']
		])
	elif 'code_list_items' in item_def_code_list:
		for code_list_item in item_def_code_list['code_list_items']:
			code_list_item_dict = {}
			for key in item_def_code_list.keys():
				if key != 'code_list_items' and key != 'code_list_oid':
					code_list_item_dict.update({
						key: item_def_code_list[key]
						})
					code_list_item_dict.update(code_list_item)
			cout.writerow([
				code_list_item_dict['item_oid'],
				code_list_item_dict['item_name'],
				code_list_item_dict['item_data_type'],
				code_list_item_dict['item_form_oids'],
				code_list_item_dict['code_list_sas'],
				code_list_item_dict['code_list_item_cval'],
				code_list_item_dict['code_list_item_ttext']
				])