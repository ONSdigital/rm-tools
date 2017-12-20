import csv
import json

with open('CE_Details_for_loading_into_RM.csv') as fp:
	reader = csv.DictReader(fp)
	with open('CE_Details_for_loading_into_RM.json', 'w') as fo:
		json.dump([row for row in reader], fo)
