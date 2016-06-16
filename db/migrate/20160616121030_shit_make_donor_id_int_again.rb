class ShitMakeDonorIdIntAgain < ActiveRecord::Migration
  def change
  	change_column :users, :donor_id, 'integer USING CAST(donor_id AS integer)'
  end
end
