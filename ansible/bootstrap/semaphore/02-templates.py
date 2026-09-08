import json, urllib.request, http.cookiejar, sys
BASE="http://127.0.0.1:3000/api"
pw=sys.argv[1]
cj=http.cookiejar.CookieJar()
op=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
def call(path, data=None, method=None):
    d=json.dumps(data).encode() if data is not None else None
    r=urllib.request.Request(BASE+path, data=d, method=method or ("POST" if d else "GET"),
                             headers={"Content-Type":"application/json"})
    return op.open(r)
call("/auth/login", {"auth":"admin","password":pw})
PID=1
# discover existing ids
inv=json.load(call(f"/project/{PID}/inventory"))[0]["id"]
repo=json.load(call(f"/project/{PID}/repositories"))[0]["id"]
env=json.load(call(f"/project/{PID}/environment"))[0]["id"]
existing={t["name"] for t in json.load(call(f"/project/{PID}/templates"))}
tpls=[
 ("Patch - containers (dry run)","playbooks/patch-guests.yml",["--check"],"Dry run of the container patch"),
 ("Patch - containers","playbooks/patch-guests.yml",[],"Pre-backup + dist-upgrade every LXC guest + notify"),
 ("Patch - hypervisors","playbooks/patch-hosts.yml",[],"Patch both PVE nodes, serial 1, NO reboot"),
 ("Reboot - hypervisors","playbooks/reboot-hosts.yml",[],"DANGER: rolling reboot of the PVE nodes, run manually"),
]
for name,pb,args,desc in tpls:
    if name in existing:
        print("skip (exists):",name); continue
    body={"project_id":PID,"name":name,"playbook":pb,"inventory_id":inv,
          "repository_id":repo,"environment_id":env,"arguments":json.dumps(args),
          "description":desc,"app":"ansible","allow_override_args_in_task":True,"type":""}
    try:
        r=call(f"/project/{PID}/templates", body)
        print("created:",name, r.status)
    except urllib.error.HTTPError as e:
        print("FAIL",name,e.code,e.read().decode()[:300])
print("templates now:", [t["name"] for t in json.load(call(f"/project/{PID}/templates"))])
