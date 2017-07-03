#getting IP
function int-ips { 
	/sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }' | grep -v lo; 
}

#getting arch
function get-arch {
	echo $(arch)
}



#getting load: 
function get-load {
 	echo $(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
}


#getting distro_name:
function get-distroname(){
	var=$(cat /etc/*{release,version} | grep DISTRIB_DESCRIPTION)
	var1=${var#*=}
	echo $var1
}

#getting distro_release:  
function get-distrorelease(){
	var=$(cat /etc/*{release,version} | grep DISTRIB_RELEASE)
	var1=${var#*=}
	echo ${var1:1:${#var1}-2}
}  


#getting distro_codename
function get-distrocodename(){
	var=$(cat /etc/*{release,version} | grep DISTRIB_CODENAME)
	var1=${var#*=}
	echo $var1
}  


#getting kernel version 
function get-kernalversion {
   echo $(uname -r)
}


#getting total mem: 
function gettotalmem {
	var=$(cat /proc/meminfo | grep MemTotal)
	var1=${var#*:}
	echo $var1
}

#getting free mem:
function getfreemem {
	var=$(cat /proc/meminfo | grep MemFree)
	var1=${var#*:}
	echo $var1
}

#getting uptime 
function getuptime {
  uptime=$(</proc/uptime)
  uptime=${uptime%%.*}
  seconds=$(( uptime%60 ))
  minutes=$(( uptime/60%60 ))
  hours=$(( uptime/60/60%24 ))
  days=$(( uptime/60/60/24 ))
  echo "$days:$minutes:$hours:$seconds"
}

#getting last boot: 
function getlastboot {
	var=$(who -b)
	var1=${var#*boot}
	echo $var1
}

#getting connect users: 
function get-connectedusers {
	echo $(who | cut -d' ' -f1 | sort | uniq)
}


#getting processes count: 
function get-processcount {
	echo $(ps -Al | grep -c bash)
}

#getting open files: 
function get-openfiles {
	echo $(cat /proc/sys/fs/file-nr)
}



#getting net received : 
function get-netreceived {

}


#getting net sent:
function get-netsent {

}
#getting load average: 
function getloadaverage(){ 
	var=$(uptime); 
	var1=${var#*average:}
	echo $var1
}



