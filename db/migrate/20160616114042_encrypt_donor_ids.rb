class EncryptDonorIds < ActiveRecord::Migration
  def change
  	
  	change_column :users, :donor_id, :string, null: true

  	add_column :users, :encrypted_donor_id, :string, null: false, default: ""
  	add_column :users, :encrypted_donor_id_iv, :string, null: false, default: ""
  	add_column :users, :di_ronod, :integer

  	User.all.each do |u|
  		if u.admin?
  			puts "Updating #{u.email}, updating column donor_id -> nil."
  			u.update_column(:donor_id, nil)
  		elsif u.donor?
  			puts "Updating #{u.email}, updating column di_ronod -> #{u.donor_id}."
  			u.update_column(:di_ronod, u.donor_id)
  		end
  	end

  end
end
