# -*- coding: utf-8 -*-
"""
Created on Mon Nov 18 15:05:59 2013

@author: ozdemircili
"""

from pysphere import VIServer
import json


# Add ips and credentials
hostname = "Vsphere"  
hostip  = "94.125.143.201"  
user   = "Administrator"  
password = "CR78aK" 


def print_datastore_status():
    server = VIServer()
    server.connect(hostip,user,password)
    for ds_mor, name in server.get_datastores().items():  
          props = VIProperty(server, ds_mor)  
          percentfree = float(props.summary.freeSpace)/float(props.summary.capacity)  
          if percentfree < 20000000:
               print "Smaller than 0.2"
          else:  
               print "bigger"
             
#Def for writing to xml output. Usage print(dict2xml(mydict, 'family'))
def dict2xml(d, root_node=None):
	wrap          =     False if None == root_node or isinstance(d, list) else True
	root          = 'objects' if None == root_node else root_node
	root_singular = root[:-1] if 's' == root[-1] and None == root_node else root
	xml           = ''
	children      = []
 
	if isinstance(d, dict):
		for key, value in dict.items(d):
			if isinstance(value, dict):
				children.append(dict2xml(value, key))
			elif isinstance(value, list):
				children.append(dict2xml(value, key))
			else:
				xml = xml + ' ' + key + '="' + str(value) + '"'
	else:
		for value in d:
			children.append(dict2xml(value, root_singular))
 
	end_tag = '>' if 0 < len(children) else '/>'
 
	if wrap or isinstance(d, dict):
		xml = '<' + root + xml + end_tag
 
	if 0 < len(children):
		for child in children:
			xml = xml + child
 
		if wrap or isinstance(d, dict):
			xml = xml + '</' + root + '>'
		
	return xml
 
 
     
#Lets create the funcion:
def vsphere():
    server = VIServer()
    server.connect(hostip,user,password)
    
    #Get clusters
    clusters = server.get_clusters()
    
    #Get datastores
    datastores = server.get_datastores()
    
    #Get datacenters
    datacenters = server.get_datacenters()

    #Get Api Type
    api_type = server.get_api_type()
    
    #Get Api version    
    apiVersion = server.get_api_version()
    
    #Get registered guests
    vmlist = server.get_registered_vms()
    
    
    #Registered guest number
    guestCount = len(vmlist)
    
    
    #Get Powered On Systems
    guestOn = server.get_registered_vms(resource_pool='/Resources', status='poweredOn')
    
    guestOnLen = len(guestOn)
    
    #Get Powered Off Systems
    guestOff = server.get_registered_vms(resource_pool='/Resources', status='poweredOff')
    
    guestOffLen = len(guestOff)
    
    #Create a nested dict to save results
    
    systems_dict = { hostname: {
    "api_version" : apiVersion,
    "api_type"    : api_type,
    "clusters": clusters, 
    "datacenters": datacenters, 
    "datastores": datastores,
    "guest_info": {
    "guest_count" : guestCount,
    "guest_on" : guestOnLen,
    "guest_off" : guestOffLen}}}
   
    
    #Convert output to Json to be sent
#    result = json.dumps(systems_dict,indent=4, sort_keys=True) < - Enable if you want json output
#    import dicttoxml
#   result = dicttoxml.dicttoxml(systems_dict) <-Didnt work that well

#   This will use dict2xml def to write dictionary as xml file to superviso.db
    result = dict2xml(systems_dict, 'hostname')
     
     #Write to a file. We use a+ here it creates if not exist and appends if it does. r+ overwrites
    
    with open('superviso.db', 'r+') as f:
        f.truncate()
        f.write(result)
        f.close()
 
                
                
#Execute the function
vsphere()

'''
sys = { hostname: {
    "api_version" : "b",
    "api_type"    : "a"}}
print(dictxml(sys, 'hostname'))
'''


''' To be implemented           
#Send it to superviso
  
# "title": "Something", "text": "Some text", "moreinfo": "Subtitle" }' http://collector.superviso.com          
import requests
import simplejson as json
auth_token = "78f5d452807955e1533f1655603aa693"
widget_id = "bcf255d701489e6362783f7d1943a41a"


url = "http://collector.superviso.com"
data = {'auth_token': 'auth1', 'widget_id': 'id1', 'title': 'Something1', 'text': 'Some text', 'moreinfo': 'Subtitle'}
headers = {'Content-type': 'application/json'}
r = requests.post(url, data=json.dumps(data), headers=headers)

r.response
'''



