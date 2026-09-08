import json, urllib.request, http.cookiejar, sys, urllib.error
BASE="http://127.0.0.1:3000/api"; pw=sys.argv[1]
cj=http.cookiejar.CookieJar()
op=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
def call(path, data=None, method=None):
    d=json.dumps(data).encode() if data is not None else None
    r=urllib.request.Request(BASE+path, data=d, method=method or ("POST" if d else "GET"),
                             headers={"Content-Type":"application/json"})
    return op.open(r)
call("/auth/login", {"auth":"admin","password":pw})
PID=1
tpl={t["name"]:t["id"] for t in json.load(call(f"/project/{PID}/templates"))}
want=[("Patch - containers","0 2 * * 6"),("Patch - hypervisors","0 3 1-7 * 0")]
for name,cron in want:
    body={"project_id":PID,"template_id":tpl[name],"cron_format":cron,"name":name+" schedule","active":True}
    try:
        r=call(f"/project/{PID}/schedules", body); print("scheduled:",name,cron,r.status)
    except urllib.error.HTTPError as e:
        print("FAIL",name,e.code,e.read().decode()[:300])
print("schedules:", [(s["name"],s["cron_format"]) for s in json.load(call(f"/project/{PID}/schedules"))])
# fire a Ping task to validate end-to-end
r=call(f"/project/{PID}/tasks", {"project_id":PID,"template_id":tpl["Ping fleet"],"debug":False})
task=json.load(r); print("ping task id:", task["id"], "status:", task.get("status"))
