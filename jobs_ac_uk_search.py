import requests
from bs4 import BeautifulSoup

baseURL = "http://www.jobs.ac.uk"
searchURL = baseURL + "/search/?keywords=research+software&salary_from=&salary_to=&category=0100&category=0200&category=0300&category=0400&category=0500&category=0600&category=0700&category=0800&category=0900&category=1000&category=1100&category=1200&category=1300&category=1400&category=1500&category=1600&category=1700&category=1800&category=1900&category=2000&category=2100&jobtype=01&jobtype=02&jobtype=03&jobtype=04&jobtype=05&jobtype=06&jobtype=07"

response = requests.get(searchURL)
outputFile = "jobs.ac.uk"

soup = BeautifulSoup(response.text, 'html.parser')
results = soup("div", class_="result")

with open(outputFile, "w") as f:
    f.write("")

for strong in soup("strong"):
    try:
        n = strong.text[:strong.text.index(" results")]
        print("Found %s results" % n)
        searchURL = "%s&show=%s" % (searchURL, (int(n)+10))
        response = requests.get(searchURL)
        soup = BeautifulSoup(response.text, 'html.parser')
        results = soup("div", class_="result")
    except Exception as e:
        pass

count = 0
for result in results:
    url = result("a")[0]['href']
    jobURL = baseURL + url
    job = requests.get(jobURL)
    if job.status_code == 200:
        count += 1
        print(jobURL)
        job_soup = BeautifulSoup(job.text, 'html.parser')
        content = job_soup(id="enhanced-content")
        if not content:
            content = job_soup("div", class_="content")
        with open(outputFile, "a") as out:
            out.write('<job url="')
            out.write(jobURL)
            out.write('">\n')
            for r in content:
                for s in r("div", class_='section'):
                    if 'id' not in s.attrs:
                        out.write("%s" % s)
            out.write("</job>\n")

print("Collected %s jobs" % count)
