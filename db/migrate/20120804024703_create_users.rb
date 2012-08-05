class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.references :company

      t.timestamps
    end
    add_index :users, :company_id
  end
end
