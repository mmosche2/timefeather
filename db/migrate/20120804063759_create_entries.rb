class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.decimal :hours
      t.text :notes
      t.date :cal_date
      t.references :user
      t.references :project

      t.timestamps
    end
    add_index :entries, :user_id
    add_index :entries, :project_id
  end
end
