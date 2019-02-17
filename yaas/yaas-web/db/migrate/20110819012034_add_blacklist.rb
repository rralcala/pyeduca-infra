class AddBlacklist < ActiveRecord::Migration
  def self.up
    create_table :blacklists do |t|
      t.string :serial_number
      t.text :reason
      
      t.timestamps
    end
  end

  def self.down
    drop_table :blacklists
  end
end
