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

require 'yaas_wrapper'

class Activation < ActiveRecord::Base

  belongs_to :user
  after_save :reduce_user_bucket
  attr_accessor :duration

  def self.custom_new(user, form_data)
    activation_data = nil

    activation = Activation.new
    activation.user_id = user.id
    activation.comments = form_data[:comments]
    activation.method = form_data[:method]
    activation.duration = form_data[:duration]

    if not form_data[:file]
      activation.errors[:base] << _("You need to provide a data file")
      return activation
    end

    f = form_data[:file].open
    hashes_list = YaasWrapper::parse_file(f)
    f.close
    hashes_list_length = hashes_list.length

    if hashes_list_length == 0
      activation.errors[:base] << _("The data file you provided has no valid elements")
      return activation
    end

    if not user.bucket_handles(hashes_list_length)
      activation.errors[:base] << _("Your activation's bucket is not enough")
      return activation
    end

    possible_hits = hashes_list.collect { |laptop| laptop["serial_number"] }
    blacklisted = Blacklist.where(:serial_number => possible_hits).first
    if blacklisted
      activation.errors[:base] << _("%s belongs to the blacklist") % blacklisted.serial_number
      return activation
    end

    begin
      case form_data[:method]
        when "Keys"
          if not user.devel_keys_allowed
            activation.errors[:base] << _("You are not authorized to generate developer keys")
            return activation
          end
          activation_data = YaasWrapper::generate_devkeys(hashes_list)

        when "Leases"
          if not user.within_limits(form_data[:duration])
            activation.errors[:base] << _("Duration must be within 1 and %d days") % user.activation_limit
            return activation
          end
          activation_data = YaasWrapper::generate_leases(hashes_list, activation.duration)
      end
    rescue SignalException, StandardError
      activation.errors[:base] << _("Activation backend reported a problem: %s") % $!
      return activation
    end

    if not activation_data
      activation.errors[:base] << _("Activation's backend reported a problem")
      return activation
    end

    activation.data = activation_data.join
    activation.bucket = activation_data.length
    activation
  end

  def filename
    return_filename = "unnamed"

    case method

      when "Keys"
        return_filename = "develop.sig"

      when "Leases"
        return_filename = "lease.sig"
    end

    return_filename
  end

  def reduce_user_bucket
    self.user.reduce_bucket(self.bucket)
  end

  # Converts plain format to canonical json format.
  def cjson_data
    cjson_data = "[1,{"

    first_one = true
    if self.data
      plain_leases = self.data.split("\n")
      plain_leases.sort!
      plain_leases.each { |plain_lease|

          serial_number = plain_lease.split()[1]
          cjson_data += "#{first_one ? "" : ","}\"#{serial_number}\":\"#{plain_lease}\n\""
          first_one = false
      }
    end

    cjson_data += "}]"
    cjson_data
  end


end
