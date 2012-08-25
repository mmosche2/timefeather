class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :user
      t.references :project

      t.timestamps
    end
    add_index :relationships, :user_id
    add_index :relationships, :project_id
    add_index :relationships, [:user_id, :project_id], unique: true
  end
end
