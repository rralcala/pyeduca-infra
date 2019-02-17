class HashPasswords < ActiveRecord::Migration
  def self.up
    add_column :users, :password_hash, :string
    User.all.each do |u|
      u.password = u.read_attribute(:password)
      u.save!
    end
    remove_column :users, :password
  end

  def self.down
    raise IrreversibleMigration.new('Cannot decrypt user passwords')
  end
end
