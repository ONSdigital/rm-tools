import csv
import json

with open('CE_Details_for_loading_into_RM.csv') as fp:
    reader = csv.DictReader(fp)
    print (reader)
    for row in reader:
        survey_id = row['Survey_Id']
        period = row['Collection_Period']
        if survey_id and period:
            filename = "%s-%s.json" % (survey_id, period)
            with open(filename, 'w') as fo:
                json.dump(row, fo)
