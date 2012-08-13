class AddBudgetedHoursToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :budgeted_hrs, :decimal
  end
end
