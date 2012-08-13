class FixActiveColumnTypo < ActiveRecord::Migration
  def up
    rename_column :users, :actve, :active
  end

  def down
  end
end
