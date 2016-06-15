class MakeDonorIdInt < ActiveRecord::Migration
  def change
  	change_column :users, :donor_id, :string, null: false
  end
end
