#!/usr/bin/ruby
#
# Daemonize and loop forever
#

require 'rubygems'
require 'daemons'


options = {
  :app_name   => "check_nodes_daemon.rb",
  :dir_mode   => :normal,
  :dir => File.join(File.dirname(__FILE__), "var"),
  :multiple   => false,
  :ontop      => false,
  :mode       => :load,
  :backtrace  => false,
  :monitor    => false
}

script_name = "check_nodes.rb"
script_path = File.join(File.dirname(__FILE__), "lib", script_name)
Daemons.run(script_path, options)
