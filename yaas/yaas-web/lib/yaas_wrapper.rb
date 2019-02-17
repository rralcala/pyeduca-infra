# Copyright Paraguay Educa 2010, Martin Abente
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#

# Yet Another Activation System - Client Wrapper

require "xmlrpc/client"
require 'socket'
include Socket::Constants

module YaasWrapper
  def self.generate_devkeys(hashes_list)
    #results = request_to_server("generate_devkeys", hashes_list)
    #results["devkeys_list"]
    request_to_bureaucrat(hashes_list, 0, 'developer')
  end

  def self.generate_leases(hashes_list, duration)
    request_to_aws(hashes_list, duration, 'lease')
  end

  def self.parse_file(file)
    hashes_list = []
    serial_numbers = {}

    file.readlines.each { |line|
      fields = line.split(/[ \t,]+/)

      if fields.length >= 2
        serial_number = fields[0].strip
        uuid = fields[1].strip

        if !serial_numbers[serial_number] and valid_serial_number(serial_number) and valid_uuid(uuid)
          #TODO: Find a better way to avoid repeated serials
          serial_numbers[serial_number] = true
          hash = {"serial_number" => serial_number.to_s, "uuid" => uuid.to_s}
          hashes_list.push(hash)
        end
      end
    }
  
    hashes_list
  end

  def self.default_activation_limit
    YAAS_CONFIG['default_activation_limit'] ? YAAS_CONFIG['default_activation_limit'].to_i : 28
  end

  def self.default_bucket
    YAAS_CONFIG['default_bucket'] ? YAAS_CONFIG['default_bucket'].to_i : 10
  end

  private

  def self.request_to_bureaucrat(hashes_list, duration, type)
    leases = []
    datetime = (Time.now + (86400*duration)).utc.strftime('%Y%m%dT%H%M%SZ')
    hashes_list.each do |laptop|
      socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
      sockaddr = Socket.pack_sockaddr_in( 9998, 'bureaucrat' )
      socket.connect( sockaddr )
      if type == 'developer'
       socket.write( "#{laptop['serial_number']}:#{laptop['uuid']}:A:00000000T000000Z" )
       results = "dev01: #{laptop['serial_number']} A 00000000T000000Z " + socket.read 
      else
        socket.write( "#{laptop['serial_number']}:#{laptop['uuid']}:K:#{datetime}" )
        results = "act01: #{laptop['serial_number']} K #{datetime} " + socket.read      
      end
      leases.push(results)
    end
    return leases
  end

  def self.request_to_server(method, *params)
    host           = YAAS_CONFIG["server"]
    port           = YAAS_CONFIG["port"]
    handler        = YAAS_CONFIG["host_handler"]
    secret_keyword = YAAS_CONFIG["secret_keyword"]

    tmp_server = XMLRPC::Client.new(host, "/RPC2", port, nil, nil, nil, nil, true, 1800)

    # As of Ruby-1.9, Net::HTTP verifies SSL certificates by default.
    # Try to disable this.
    http = tmp_server.instance_variable_get(:@http)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if !http.nil?

    tmp_server.call("#{handler}.#{method}", secret_keyword, *params)
  end

  def self.valid_serial_number(serial_number)
    return true if serial_number.upcase.match("^[A-Z]{3}[(0-9)|(A-F)]{8}$")
    false
  end

  def self.valid_uuid(uuid)
    return true if uuid.upcase.match("^[(0-9)|(A-F)]{8}(-[(0-9)|(A-F)]{4}){3}-[(0-9)|(A-F)]{12}$")
    false
  end

end
