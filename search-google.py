from googleapiclient.discovery import build
import pprint
import json

my_api_key = "AIzaSyDu9Urnt73g_A7PJnyLL3Lx8RNT3Rie3CA"
my_cse_id = "002054149817775965723:tkay__adnzi"

def google_search(search_term, api_key, cse_id, **kwargs):
    service = build("customsearch", "v1", developerKey=api_key)
    res = service.cse().list(q=search_term, cx=cse_id, **kwargs).execute()
    return res['items']

results = google_search('big-data site:cam.ac.uk', my_api_key, my_cse_id, num=10)

with open('data.txt', 'w') as outfile:
    print("clear file")

outfile.close()

for result in results:
    site = result.get('htmlFormattedUrl')
    print(site)
    # with open('data.txt', 'a') as outfile:
    #     outfile.write(json.dumps(result))
    # outfile.close()
    # pprint.pprint(result)
