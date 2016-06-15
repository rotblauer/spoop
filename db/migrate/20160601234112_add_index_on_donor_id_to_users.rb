class AddIndexOnDonorIdToUsers < ActiveRecord::Migration
  def change
  	add_index :users, :donor_id, unique: true
  end
end
