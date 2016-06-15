class AddIndexToEncryptedEmailToUsers < ActiveRecord::Migration
  def change
  	add_index :users, :encrypted_email
  end
end
