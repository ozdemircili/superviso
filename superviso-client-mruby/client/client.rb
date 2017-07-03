
### CPU
class Cpu
  attr_reader :cpuinfo, :real_cpu, :cpu_number
  def initialize
    @cpuinfo = Hash.new
    @real_cpu = Hash.new
    @cpu_number = 0
    current_cpu = nil
    File.open("/proc/cpuinfo").each do |line|
      case line
      when /processor\s+:\s(.+)/
        @cpuinfo[$1] = Hash.new
        @cpuinfo[$1][:usage_sum] = []
        @cpuinfo[$1][:total] = []
        current_cpu = $1
        @cpu_number += 1
      when /vendor_id\s+:\s(.+)/
        @cpuinfo[current_cpu]["vendor_id"] = $1
      when /cpu family\s+:\s(.+)/
        @cpuinfo[current_cpu]["family"] = $1
      when /model\s+:\s(.+)/
        @cpuinfo[current_cpu]["model"] = $1
      when /stepping\s+:\s(.+)/
        @cpuinfo[current_cpu]["stepping"] = $1
      when /physical id\s+:\s(.+)/
        @cpuinfo[current_cpu]["physical_id"] = $1
        @real_cpu[$1] = true
      when /core id\s+:\s(.+)/
        @cpuinfo[current_cpu]["core_id"] = $1
      when /cpu cores\s+:\s(.+)/
        @cpuinfo[current_cpu]["cores"] = $1
      when /model name\s+:\s(.+)/
        @cpuinfo[current_cpu]["model_name"] = $1
      when /cpu MHz\s+:\s(.+)/
        @cpuinfo[current_cpu]["mhz"] = $1
      when /cache size\s+:\s(.+)/
        @cpuinfo[current_cpu]["cache_size"] = $1
      when /flags\s+:\s(.+)/
        @cpuinfo[current_cpu]["flags"] = $1.split(' ')
      end
    end

    cpu_usage
  end

  def cpu_usage
    #First Read
    File.open("/proc/stat").each do |line|
      if line =~ /^cpu([0-9]+)/
        data = line.split(" ").map{|e| e.to_i}
        @cpuinfo[$1][:usage_sum] << data[1..3].inject(:+)
        @cpuinfo[$1][:total] << data[1..4].inject(:+)
      end
    end
    Sleep::sleep(1)
    #Second Read
    File.open("/proc/stat").each do |line|
      if line =~ /^cpu([0-9]+)/
        data = line.split(" ").map{|e| e.to_i}
        @cpuinfo[$1][:usage_sum] << data[1..3].inject(:+)
        @cpuinfo[$1][:total] << data[1..4].inject(:+)
      end
    end

    0.upto(@cpu_number-1) do |i|
      i = i.to_s
      puts @cpuinfo[i]
      @cpuinfo[i][:usage_perc] = 100*(@cpuinfo[i][:usage_sum].inject(:-).abs / @cpuinfo[i][:total].inject(:-).abs)
    end
  end
end

### FILESYSTEM
fs = Hash.new

# Grab filesystem data from df
so = IO.popen("df -P")
so.readlines.each  do |line|
  case line
  when /^Filesystem\s+1024-blocks/
    next
  when /^(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+\%)\s+(.+)$/
    filesystem = $1
    fs[filesystem] = Hash.new
    fs[filesystem][:kb_size] = $2
    fs[filesystem][:kb_used] = $3
    fs[filesystem][:kb_available] = $4
    fs[filesystem][:percent_used] = $5
    fs[filesystem][:mount] = $6
  end
end 

# Grab mount information from /bin/mount
so = IO.popen("mount")
so.readlines.each do |line|
  if line =~ /^(.+?) on (.+?) type (.+?) \((.+?)\)$/
    filesystem = $1
    fs[filesystem] = Hash.new unless fs.has_key?(filesystem)
    fs[filesystem][:mount] = $2
    fs[filesystem][:fs_type] = $3
    fs[filesystem][:mount_options] = $4.split(",")
  end
end

# Gather more filesystem types via libuuid, even devices that's aren't mounted
so = IO.popen("blkid -s TYPE")
so.readlines.each do |line|
  if line =~ /^(\S+): TYPE="(\S+)"/
    filesystem = $1
    fs[filesystem] = Hash.new unless fs.has_key?(filesystem)
    fs[filesystem][:fs_type] = $2
  end
end

# Gather device UUIDs via libuuid
so = IO.popen("blkid -s UUID")
so.readlines.each do |line|
  if line =~ /^(\S+): UUID="(\S+)"/
    filesystem = $1
    fs[filesystem] = Hash.new unless fs.has_key?(filesystem)
    fs[filesystem][:uuid] = $2
  end
end

# Gather device labels via libuuid
so = IO.popen("blkid -s LABEL")
so.readlines.each do |line|
  if line =~ /^(\S+): LABEL="(\S+)"/
    filesystem = $1
    fs[filesystem] = Hash.new unless fs.has_key?(filesystem)
    fs[filesystem][:label] = $2
  end
end

# Grab any missing mount information from /proc/mounts
if File.exists?('/proc/mounts')
  File.open('/proc/mounts').readlines.each do |line|
    if line =~ /^(\S+) (\S+) (\S+) (\S+) \S+ \S+$/
      filesystem = $1
      next if fs.has_key?(filesystem)
      fs[filesystem] = Hash.new
      fs[filesystem][:mount] = $2
      fs[filesystem][:fs_type] = $3
      fs[filesystem][:mount_options] = $4.split(",")
    end
  end
end


### MEMORY
class Memory
  attr_reader :memory, :total, :used
  def initialize
    @memory = Hash.new
    @memory[:swap] = Hash.new

    File.open("/proc/meminfo").each do |line|
      case line
      when /^MemTotal:\s+(\d+) (.+)$/
        @memory[:total] = "#{$1}".to_i
      when /^MemFree:\s+(\d+) (.+)$/
        @memory[:free] = "#{$1}".to_i
      when /^Buffers:\s+(\d+) (.+)$/
        @memory[:buffers] = "#{$1}#{$2}"
      when /^Cached:\s+(\d+) (.+)$/
        @memory[:cached] = "#{$1}#{$2}"
      when /^Active:\s+(\d+) (.+)$/
        @memory[:active] = "#{$1}#{$2}"
      when /^Inactive:\s+(\d+) (.+)$/
        @memory[:inactive] = "#{$1}#{$2}"
      when /^HighTotal:\s+(\d+) (.+)$/
        @memory[:high_total] = "#{$1}#{$2}"
      when /^HighFree:\s+(\d+) (.+)$/
        @memory[:high_free] = "#{$1}#{$2}"
      when /^LowTotal:\s+(\d+) (.+)$/
        @memory[:low_total] = "#{$1}#{$2}"
      when /^LowFree:\s+(\d+) (.+)$/
        @memory[:low_free] = "#{$1}#{$2}"
      when /^SwapCached:\s+(\d+) (.+)$/
        @memory[:swap][:cached] = "#{$1}#{$2}"
      when /^SwapTotal:\s+(\d+) (.+)$/
        @memory[:swap][:total] = "#{$1}#{$2}"
      when /^SwapFree:\s+(\d+) (.+)$/
        @memory[:swap][:free] = "#{$1}#{$2}"
      end
    end
  end

  def total
    return @memory[:total]
  end
  def used
    return @memory[:total]-@memory[:free]
  end
end
### NETWORK
def linux_encaps_lookup(encap)
  return "Loopback" if encap.eql?("Local Loopback") || encap.eql?("loopback")
  return "PPP" if encap.eql?("Point-to-Point Protocol")
  return "SLIP" if encap.eql?("Serial Line IP")
  return "VJSLIP" if encap.eql?("VJ Serial Line IP")
  return "IPIP" if encap.eql?("IPIP Tunnel")
  return "6to4" if encap.eql?("IPv6-in-IPv4")
  return "Ethernet" if encap.eql?("ether")
  encap
end

iface = Hash.new
net_counters = Hash.new

network = Hash.new unless network
network[:interfaces] = Hash.new unless network[:interfaces]
counters = Hash.new unless counters
counters[:network] = Hash.new unless counters[:network]

IPROUTE_INT_REGEX = /^(\d+): ([0-9a-zA-Z@:\.\-_]*?)(@[0-9a-zA-Z]+|):\s/

families = [{
  :name => "inet",
  :default_route => "0.0.0.0/0",
  :default_prefix => :default,
  :neighbour_attribute => :arp
},{
  :name => "inet6",
  :default_route => "::/0",
  :default_prefix => :default_inet6,
  :neighbour_attribute => :neighbour_inet6
}]

so = IO.popen("ip addr")
cint = nil
so.readlines.each do |line|
  if line =~ IPROUTE_INT_REGEX
    cint = $2
    iface[cint] = Hash.new
    if cint =~ /^(\w+)(\d+.*)/
      iface[cint][:type] = $1
      iface[cint][:number] = $2
    end

    if line =~ /mtu (\d+)/
      iface[cint][:mtu] = $1
    end

    flags = line.scan(/(UP|BROADCAST|DEBUG|LOOPBACK|POINTTOPOINT|NOTRAILERS|LOWER_UP|NOARP|PROMISC|ALLMULTI|SLAVE|MASTER|MULTICAST|DYNAMIC)/)
    if flags.length > 1
      iface[cint][:flags] = flags.flatten.uniq
    end
  end
  if line =~ /link\/(\w+) ([\da-f\:]+) /
    iface[cint][:encapsulation] = linux_encaps_lookup($1)
    unless $2 == "00:00:00:00:00:00"
      iface[cint][:addresses] = Hash.new unless iface[cint][:addresses]
      iface[cint][:addresses][$2.upcase] = { "family" => "lladdr" }
    end
  end
  if line =~ /inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(\/(\d{1,2}))?/
    tmp_addr, tmp_prefix = $1, $3
    tmp_prefix ||= "32"
    original_int = nil

    # Are we a formerly aliased interface?
    if line =~ /#{cint}:(\d+)$/
      sub_int = $1
      alias_int = "#{cint}:#{sub_int}"
      original_int = cint
      cint = alias_int
    end

    iface[cint] = Hash.new unless iface[cint] # Create the fake alias interface if needed
    iface[cint][:addresses] = Hash.new unless iface[cint][:addresses]
    iface[cint][:addresses][tmp_addr] = { "family" => "inet", "prefixlen" => tmp_prefix }
    # Bug in mruby-ipaddr Integer.div not implemented
    #iface[cint][:addresses][tmp_addr][:netmask] = IPAddr.new("255.255.255.255").mask(tmp_prefix.to_i).to_s

    if line =~ /peer (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      iface[cint][:addresses][tmp_addr][:peer] = $1
    end

    if line =~ /brd (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      iface[cint][:addresses][tmp_addr][:broadcast] = $1
    end

    if line =~ /scope (\w+)/
      iface[cint][:addresses][tmp_addr][:scope] = ($1.eql?("host") ? "Node" : $1.capitalize)
    end

    # If we found we were an an alias interface, restore cint to its original value
    cint = original_int unless original_int.nil?
  end
  if line =~ /inet6 ([a-f0-9\:]+)\/(\d+) scope (\w+)/
    iface[cint][:addresses] = Hash.new unless iface[cint][:addresses]
    tmp_addr = $1
    iface[cint][:addresses][tmp_addr] = { "family" => "inet6", "prefixlen" => $2, "scope" => ($3.eql?("host") ? "Node" : $3.capitalize) }
  end
end

so = IO.popen("ip -d -s link")
tmp_int = nil
on_rx = true
so.readlines.each do |line|
  if line =~ IPROUTE_INT_REGEX
    tmp_int = $2
    net_counters[tmp_int] = Hash.new unless net_counters[tmp_int]
  end

  if line =~ /(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
    int = on_rx ? :rx : :tx
    net_counters[tmp_int][int] = Hash.new unless net_counters[tmp_int][int]
    net_counters[tmp_int][int][:bytes] = $1
    net_counters[tmp_int][int][:packets] = $2
    net_counters[tmp_int][int][:errors] = $3
    net_counters[tmp_int][int][:drop] = $4
    if(int == :rx)
      net_counters[tmp_int][int][:overrun] = $5
    else
      net_counters[tmp_int][int][:carrier] = $5
      net_counters[tmp_int][int][:collisions] = $6
    end

    on_rx = !on_rx
  end

  if line =~ /qlen (\d+)/
    net_counters[tmp_int][:tx] = Hash.new unless net_counters[tmp_int][:tx]
    net_counters[tmp_int][:tx][:queuelen] = $1
  end

  if line =~ /vlan id (\d+)/
    tmp_id = $1
    iface[tmp_int][:vlan] = Hash.new unless iface[tmp_int][:vlan]
    iface[tmp_int][:vlan][:id] = tmp_id

    vlan_flags = line.scan(/(REORDER_HDR|GVRP|LOOSE_BINDING)/)
    if vlan_flags.length > 0
      iface[tmp_int][:vlan][:flags] = vlan_flags.flatten.uniq
    end
  end

  if line =~ /state (\w+)/
    iface[tmp_int]['state'] = $1.downcase
  end
end

counters[:network][:interfaces] = net_counters
network["interfaces"] = iface


### PLATFORM INFO
lsb = Hash.new

if File.exists?("/etc/lsb-release")
  File.open("/etc/lsb-release").each do |line|
    case line
    when /^DISTRIB_ID=["']?(.+?)["']?$/
      lsb[:id] = $1
    when /^DISTRIB_RELEASE=["']?(.+?)["']?$/
      lsb[:release] = $1
    when /^DISTRIB_CODENAME=["']?(.+?)["']?$/
      lsb[:codename] = $1
    when /^DISTRIB_DESCRIPTION=["']?(.+?)["']?$/
      lsb[:description] = $1
    end
  end
elsif File.exists?("/usr/bin/lsb_release")
  # Fedora/Redhat, requires redhat-lsb package
  so = shell_out("lsb_release -a")
  so.stdout.lines do |line|
    case line
    when /^Distributor ID:\s+(.+)$/
      lsb[:id] = $1
    when /^Description:\s+(.+)$/
      lsb[:description] = $1
    when /^Release:\s+(.+)$/
      lsb[:release] = $1
    when /^Codename:\s+(.+)$/
      lsb[:codename] = $1
    else
      lsb[:id] = line
    end
  end
end
def get_redhatish_platform(contents)
  contents[/^Red Hat/i] ? "redhat" : contents[/(\w+)/i, 1].downcase
end

def get_redhatish_version(contents)
  contents[/Rawhide/i] ? contents[/((\d+) \(Rawhide\))/i, 1].downcase : contents[/release ([\d\.]+)/, 1]
end

# platform [ and platform_version ? ] should be lower case to avoid dealing with RedHat/Redhat/redhat matching 
if File.exists?("/etc/oracle-release")
  contents = File.read("/etc/oracle-release").chomp
  platform = "oracle"
  platform_version get_redhatish_version(contents)
elsif File.exists?("/etc/enterprise-release")
  contents = File.read("/etc/enterprise-release").chomp
  platform = "oracle"
  platform_version get_redhatish_version(contents)
elsif File.exists?("/etc/debian_version")
  # Ubuntu and Debian both have /etc/debian_version
  # Ubuntu should always have a working lsb, debian does not by default
  if lsb[:id] =~ /Ubuntu/i
    platform = "ubuntu"
    platform_version = lsb[:release]
  elsif lsb[:id] =~ /LinuxMint/i
    platform = "linuxmint"
    platform_version = lsb[:release]
  else 
    if File.exists?("/usr/bin/raspi-config")
      platform = "raspbian"
    else
      platform = "debian"
    end
    platform_version = File.read("/etc/debian_version").chomp
  end
elsif File.exists?("/etc/redhat-release")
  contents = File.read("/etc/redhat-release").chomp
  platform get_redhatish_platform(contents)
  platform_version get_redhatish_version(contents)
elsif File.exists?("/etc/system-release")
  contents = File.read("/etc/system-release").chomp
  platform get_redhatish_platform(contents)
  platform_version get_redhatish_version(contents)
elsif File.exists?('/etc/gentoo-release')
  platform = "gentoo"
  platform_version File.read('/etc/gentoo-release').scan(/(\d+|\.+)/).join
elsif File.exists?('/etc/SuSE-release')
  platform = "suse"
  suse_release = File.read("/etc/SuSE-release")
  platform_version = suse_release.scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join(".")
  platform_version = suse_release.scan(/VERSION = ([\d\.]{2,})/).flatten.join(".") if platform_version == ""
elsif File.exists?('/etc/slackware-version')
  platform = "slackware"
  platform_version File.read("/etc/slackware-version").scan(/(\d+|\.+)/).join
elsif File.exists?('/etc/arch-release')
  platform = "arch"
  # no way to determine platform_version in a rolling release distribution
  # kernel release will be used - ex. 2.6.32-ARCH
elsif lsb[:id] =~ /RedHat/i
  platform = "redhat"
  platform_version = lsb[:release]
elsif lsb[:id] =~ /Amazon/i
  platform = "amazon"
  platform_version = lsb[:release]
elsif lsb[:id] =~ /ScientificSL/i
  platform = "scientific"
  platform_version = lsb[:release]
elsif lsb[:id] =~ /XenServer/i
  platform = "xenserver"
  platform_version = lsb[:release]
elsif lsb[:id] # LSB can provide odd data that changes between releases, so we currently fall back on it rather than dealing with its subtleties 
  platform = lsb[:id].downcase
  platform_version = lsb[:release]
end

case platform
when /debian/, /ubuntu/, /linuxmint/, /raspbian/
  platform_family = "debian"
when /fedora/
  platform_family = "fedora"
when /oracle/, /centos/, /redhat/, /scientific/, /enterpriseenterprise/, /amazon/, /xenserver/, /cloudlinux/ # Note that 'enterpriseenterprise' is oracle's LSB "distributor ID"
  platform_family = "rhel"
when /suse/
  platform_family = "suse"
when /gentoo/
  platform_family = "gentoo"
when /slackware/
  platform_family = "slackware"
when /arch/ 
  platform_family = "arch" 
end



class Generic
  def self.hostname
    IO.popen("hostname").read
  end

  def self.load_averages
    if IO.popen("uptime").read =~ /load average:(.+)$/
      load_averages = $1.split(",").map{|l| l.strip}
    end
  end

  def self.uptime
    uptime, idletime = File.open("/proc/uptime").gets.split(" ")
    uptime.to_i
#    idletime_seconds = idletime.to_i
  end
end
class Platform
  
  attr_reader :lsb

  def initialize
    @lsb = {}
    if File.exists?("/etc/lsb-release")
      File.open("/etc/lsb-release").each do |line|
        case line
        when /^DISTRIB_ID=["']?(.+?)["']?$/
          @lsb[:id] = $1
        when /^DISTRIB_RELEASE=["']?(.+?)["']?$/
          @lsb[:release] = $1
        when /^DISTRIB_CODENAME=["']?(.+?)["']?$/
          @lsb[:codename] = $1
        when /^DISTRIB_DESCRIPTION=["']?(.+?)["']?$/
          @lsb[:description] = $1
        end
      end
    elsif File.exists?("/usr/bin/lsb_release")
      # Fedora/Redhat, requires redhat-lsb package
      so = shell_out("lsb_release -a")
      so.stdout.lines do |line|
        case line
        when /^Distributor ID:\s+(.+)$/
          @lsb[:id] = $1
        when /^Description:\s+(.+)$/
          @lsb[:description] = $1
        when /^Release:\s+(.+)$/
          @lsb[:release] = $1
        when /^Codename:\s+(.+)$/
          @lsb[:codename] = $1
        else
          @lsb[:id] = line
        end
      end
    end
  end
  def get_redhatish_platform(contents)
    contents[/^Red Hat/i] ? "redhat" : contents[/(\w+)/i, 1].downcase
  end

  def get_redhatish_version(contents)
    contents[/Rawhide/i] ? contents[/((\d+) \(Rawhide\))/i, 1].downcase : contents[/release ([\d\.]+)/, 1]
  end
end

=begin
puts cpuinfo
puts fs

  puts "#{real_cpu.keys.size} CPU"
  puts "#{cpu_number} Cores"

  cpuinfo.each do |cpu, info|
    puts "#{cpu} - #{info["model_name"]}"
  end

  fs.each do |partition, filesystem|
    puts "Partition: #{partition} mountpoint: #{filesystem[:mount]} used: #{filesystem[:percent_used]}"
  end

puts Memory.new().total
puts network
puts counters
puts Platform.new().lsb
puts platform
puts platform_family 
puts platform_version
puts Generic.uptime
puts Generic.hostname
puts Generic.load_averages
=end

def build_payload(type)
  case type
  when "host_info"
    lsb = Platform.new().lsb
    {title: Generic.hostname, moreinfo: lsb[:description]}
  when "memory_info"
    memory = Memory.new
    {title: "Memory Info", max: memory.total, value: memory.used}
  when "cpu_info"
    cpu = Cpu.new
    { 
      title: "CPUs",
      progress_items: cpu.cpuinfo.map { |cpu, info|
        { name: "CPU#{cpu}", progress: info[:usage_perc]}
      }
    }
  end
end


json_config = File.open("/etc/superviso/config.json").read
config = JSON.parse(json_config)
h = HttpRequest.new()

body = {
  auth_token: config["auth_token"], 
  widgets: config["widgets"].map do |type, secret|
    build_payload(type).merge!({widget: secret})
  end
}
p h.post(config["end_point"],JSON::stringify(body), {"Content-Type" => "application/json"}) 
