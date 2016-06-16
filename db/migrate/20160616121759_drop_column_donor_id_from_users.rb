class DropColumnDonorIdFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :donor_id
  end
end
