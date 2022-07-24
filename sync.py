from __future__ import print_function
from google.oauth2 import service_account
from googleapiclient.discovery import build
import configparser
import json

SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
SERVICE_ACCOUNT_FILE = 'service.json'
credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES)

def settings_read():
    config = configparser.ConfigParser(allow_no_value=True)
    config.read('./sync.settings.cfg')
    settings = {} 
    for s in config.sections():
        settings[s]={}
        for k,v in config.items(s):
            if v.isdigit():
                v=int(v)
            if isinstance(v, str):
                if v.lower()=="false":
                    v=False
                elif v.lower()=="true":
                    v=True
                elif v=="":
                    v=None
            settings[s][k]=v
    return settings

def gsheets_read(cfg):
    # Call the Sheets API
    service = build('sheets', 'v4', credentials=credentials)
    result = service.spreadsheets().values().get(spreadsheetId=cfg['spreadsheet_id'],range=cfg['range_name']).execute()
    data = result.get('values')
    #Username	Goedgekeurd
    #Naam   FALSE / TRUE
    jsonraw=[]
    for rows in data[1:-1]:
        jsonraw+=[{data[0][0]:rows[0],data[0][1]:rows[1]}]
    json_string = json.dumps(jsonraw)
    with open('sheet.tmp.json', 'w') as outfile:
        outfile.write(json_string)

def main():
    settings=settings_read()
    gsheets_read(cfg=settings['gsheets'])

if __name__ == '__main__':
    main()