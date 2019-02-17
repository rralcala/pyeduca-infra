class Blacklist < ActiveRecord::Base

  validates_presence_of :serial_number
  attr_accessible :serial_number, :reason

end
