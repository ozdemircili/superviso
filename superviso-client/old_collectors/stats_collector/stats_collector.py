import pylinux.pylinux as pylinux

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
    for dev in net_devs.keys():
        sys_dict['net_received'] =  dev +  ': ' +   str(net_devs[dev].rx)
        sys_dict['net_transmitted'] =  dev +  ': ' + str(net_devs[dev].tx)
     
    #Get cpu info
    pylinux_cpuinfo = pylinux.cpuinfo()

    for key in pylinux_cpuinfo.keys():
        print key,": ",pylinux_cpuinfo[key]
  #  print pylinux_cpuinfo
 #   for i,key in enumerate(pylinux_cpuinfo.keys()):
 #     sys_dict['cpu'] =   'Processor: {0} Physical ID: {1}'.format(i,pylinux_cpuinfo[key]['physical id'])
    
    #Convert to json
    for key in sys_dict.keys():
        print key,": ",sys_dict[key]
  #  print sys_dict

if __name__=="__main__":
    rasp_info()