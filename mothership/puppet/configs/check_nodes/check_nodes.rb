#!/usr/bin/ruby
#
# Get the list of nodes from a conf file and loop 
# forever checking status (via tcp ping) and update 
# their status via ActiveResource 
#


require File.join(File.dirname(__FILE__), 'node.rb')
require 'ping'
require "socket"

class NetworkNode

  def initialize(node_id, ip_address)
    @node_id = node_id
    @ip_address = ip_address
  end

  def update_status()
    stat = get_status()
    Node.setStatus(@node_id, stat)
  end

  private 
  def get_status()
    Ping.pingecho(@ip_address) ? :up : :down
  end

end

class CheckNodes

  SLEEP_TIME = 120
  MAX_RETRIES = 3
  CONF_FILE = File.join(File.dirname(__FILE__), "../etc", "nodes.conf")

  def initialize(conf_file = CheckNodes::CONF_FILE)

    @conf_file = conf_file

    readConfFile()

    @site = getConfKey("site")
    @user = getConfKey("user")
    @password = getConfKey("password")
    @sleep_time = getConfKey("sleep_time") || CheckNodes::SLEEP_TIME
    @sleep_time = @sleep_time.to_i
    @hostname = Socket.gethostname
  end
  

  def run
    nodes = getNodes()

    if nodes != []
      while true
        begin 
          nodes.each { |n|
            n.update_status()
          }
        rescue
          Node.log("run loop : " + $!.to_s)
        end
        sleep(@sleep_time)
      end
    else
      Node.log("ZERO nodes retrieved.")
    end
  end

  private 
  def getNodes()
    Node.set_params(@site, @user, @password)

    nodes = []
    while (nodes == [])
      nodes = Node.allNodesAt(@hostname)
      sleep(@sleep_time) if nodes == []
    end
    nodes.map { |n|
      NetworkNode.new(n["id"], n["ip_address"])
    }
  end

  def readConfFile()
    @conf_settings = Hash.new
    File.open(@conf_file, "r") do |fp|
      lines = fp.readlines()
      lines.each { |l|
        next if l.match(/^#/)
        l.chomp!
        k,v = l.split("=")
        k = clean_str(k)
        v = clean_str(v)
        @conf_settings[k] = v
      }
    end
    @conf_settings
  end

  def getConfKey(k)
    @conf_settings[k]
  end

  def clean_str(s)
    ret = s
    ret.gsub!(/\"/, "") if ret.match(/\"/)
    ret.gsub!(/ /, "") if ret.match(/ /)
    ret
  end

end


# main 
cn = CheckNodes.new
cn.run()

