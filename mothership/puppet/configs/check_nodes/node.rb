#!/usr/bin/ruby
#
# Class that provides access to the ActiveResource 
#

require "rubygems"
require "activeresource"
require "digest/sha1"
require "logger"


class Node < ActiveResource::Base

  LOG_PATH = File.join(File.dirname(__FILE__),"..","logs","errors.log")

  def self.set_params(site, user, password)
    self.site = site
    self.user = user
    self.password = Digest::SHA1.hexdigest(password)
    true
  end

  def self.setStatus(id, stat)
    begin
      obj = self.find(id)
      obj.put(stat)
    rescue
      err_msg = "Node with id #{id} not found"
      self.log(err_msg)
    end
  end

  def self.allNodesAt(hostname)
    nodes = []
    begin
      nodes = Node.get(:allNodesAt, :hostname => hostname)
    rescue
      err_msg = "Error while retrieving nodes."
      self.log(err_msg)
      nodes = []
    end
    nodes
  end

  ###
  # log error msg
  #
  def self.log(msg)
    @@logger ||= Logger.new(LOG_PATH)
    @@logger.error(msg)
  end

end


