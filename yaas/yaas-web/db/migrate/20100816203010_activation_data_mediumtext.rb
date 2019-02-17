class ActivationDataMediumtext < ActiveRecord::Migration
  def self.up
    # Use MEDIUMTEXT so that we can store more than 64kb
    change_column :activations, :data, :text, :limit => 16777215
  end

  def self.down
    change_column :activations, :data, :text
  end
end
