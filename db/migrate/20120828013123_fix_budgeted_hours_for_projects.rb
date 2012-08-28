class FixBudgetedHoursForProjects < ActiveRecord::Migration
  def change
      rename_column :projects, :budgeted_hrs, :budgeted_dollars
  end
end
