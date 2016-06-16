class AddColumnDonorIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :donor_id, :integer

  	User.donors.all.each do |d|
  		d.update_attributes(donor_id: d.di_ronod)
  	end
  end
end
