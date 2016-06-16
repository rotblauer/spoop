class MakeDonorIdIntAgain < ActiveRecord::Migration
  def change
  	remove_index :users, :donor_id
  	change_column :users, :donor_id, 'integer USING CAST(donor_id AS integer)'
  	add_index :users, :donor_id
  end
end
