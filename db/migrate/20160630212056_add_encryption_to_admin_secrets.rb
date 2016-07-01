class AddEncryptionToAdminSecrets < ActiveRecord::Migration
  def change
  	add_column :users, :encrypted_admin_secret, :string
  	add_column :users, :encrypted_admin_secret_iv, :string
  	remove_column :users, :admin_secret

  	User.admins.all.each do |a|
  		a.update_attributes!(admin_secret: ENV['admin_secret'])
  	end
  end
end
