class DropPointlessEncryptionColumns < ActiveRecord::Migration
  def change
  	remove_column :users, :encrypted_email
  	remove_column :users, :encrypted_email_iv
  	remove_column :users, :di_ronod
  	remove_column :users, :encrypted_donor_id
  	remove_column :users, :encrypted_donor_id_iv
  end
end
