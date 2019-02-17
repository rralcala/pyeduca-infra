class CreateActivations < ActiveRecord::Migration
  def self.up
    create_table :activations do |t|
      t.integer :user_id
      t.text    :comments
      t.integer :bucket
      t.text    :data
      t.string  :method

      t.timestamps
    end
  end

  def self.down
    drop_table :activations
  end
end
