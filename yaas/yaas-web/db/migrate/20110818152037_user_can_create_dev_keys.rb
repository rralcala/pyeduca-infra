class UserCanCreateDevKeys < ActiveRecord::Migration
  def self.up
    change_table :users do |f|
      f.boolean :can_create_dev_keys, :default => false
    end
  end

  def self.down
    remove_column :users, :can_create_dev_keys
  end
end
