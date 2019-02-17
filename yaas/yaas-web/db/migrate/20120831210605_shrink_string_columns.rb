class ShrinkStringColumns < ActiveRecord::Migration
  def self.up
    # This column is used in indexes.
    # When we use utf8 we can't store 255-character fields in indexes.
    # So shrink them to 100 which is a more sensible size.
    change_column "schema_migrations", "version", :string, :limit => 100
  end

  def self.down
  end
end
