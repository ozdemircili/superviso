# -*- coding: utf-8 -*-
"""
Created on Wed Dec  4 11:45:24 2013

@author: ozdemircili
"""

#!/usr/bin/python

import pylinux.pylinux as pylinux
import json
import subprocess

def rasp_info():
    #Distro related
    sys_dict = {}
    sys_dict['hostname'] = pylinux.hostname()
    sys_dict['ip'] = pylinux.ipaddr()
    sys_dict['arch'] = pylinux.arch()
    sys_dict['load'] = pylinux.avg_load()
    sys_dict['distro_name'] = pylinux.distro_name()
    sys_dict['distro_rel'] =  pylinux.distro_release()
    sys_dict['distro_nic'] =  pylinux.distro_nickname()
    sys_dict['kernel'] = pylinux.kernel()
    sys_dict['total_mem'] = pylinux.totalmem()
    sys_dict['free_mem'] = pylinux.freemem()
    sys_dict['uptime'] = pylinux.uptime()
    sys_dict['last_boot'] = pylinux.last_boot()
    sys_dict['users'] = pylinux.users()
    sys_dict['process_count'] =  len(pylinux.processes())
    sys_dict['open_files'] =  pylinux.lsof()
    
    
    #Get net stats
    net_devs = pylinux.netdevs()
    print 'Network Devices:: '
    for dev in net_devs.keys():
        sys_dict['net_received'] =  dev +  ': ' +   str(net_devs[dev].rx)
        sys_dict['net_transmitted'] =  dev +  ': ' + str(net_devs[dev].tx)
     
    #Get cpu info
    pylinux_cpuinfo = pylinux.cpuinfo()
    for i,key in enumerate(pylinux_cpuinfo.keys()):
       sys_dict['cpu'] =   'Processor: {0} Physical ID: {1}'.format(i,pylinux_cpuinfo[key]['physical id'])
    
    #Convert to json
    result = json.dumps(sys_dict)
    
    #Write to screen 
    #return result
    
    with open('/etc/superviso/data/raspberry.db', 'a+') as f:
        f.truncate()
        f.write(result)
        f.close()
        
    #Let`s read the config
    config = json.loads(open('/etc/superviso/config.json').read())
    endpoint = config["end_point"]
    auth = config["auth_token"]
    config["widgets"]

def send_info():
    import json
    import subprocess

    #Read the config file:
    configfile = "/etc/superviso/config.json"
    
    with open(configfile) as cfile:    
        data = json.load(cfile)
    
    endpoint= data["end_point"]
    hostinfo= data["widgets"]["host_info"] 
    meminfo = data["widgets"]["memory_info"]
    cpuinfo = data["widgets"]["cpu_info"]  


       #Send using subprocess
    import subprocess
    subprocess.call([
    'curl',
    '-X',
    'POST',
    '-H',
    'Content-Type: application/json',
    '-d',
    '{ "auth_token": "e91a0ffe758c194f0d1d5896eb4daed0", "widget": "329bdbea887ad8e10e4e496f7a60f898", "title": "Something", "items":[{"label": "OZZYBOUGHT BREAD FOR", "value": "$999.99"}, {"label": "SOLD WATER FOR", "value": "$9,001.00"}] }',
    'http://collector.superviso.com'
     


rasp_info()