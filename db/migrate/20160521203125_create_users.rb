class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :donor_id
      t.string :role
      t.string :name
      t.datetime :donor_since 
      
      t.timestamps null: false
    end
  end
end
