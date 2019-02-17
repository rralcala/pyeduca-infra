class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :name
      t.string  :password
      t.boolean :admin
      t.string  :email
      t.integer :bucket
      t.integer :activation_limit

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
