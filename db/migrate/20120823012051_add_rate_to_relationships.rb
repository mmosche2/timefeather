class AddRateToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :rate, :decimal
    add_column :relationships, :staffing_start, :date
    add_column :relationships, :staffing_end, :date
    add_column :relationships, :budgeted_hrs, :decimal
  end
end
