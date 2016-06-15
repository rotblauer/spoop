class AddEncryptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_email, :string, null: false, default: ''
    add_column :users, :encrypted_email_iv, :string, null: false, default: ''
    add_column :users, :liame, :string

    User.all.each_with_index do |u, i|
    	u.update_attribute(:liame, u.email)
    	u.update_attribute(:donor_id, 10000 + i) if u.donor_id.nil?
    end

    change_column_null :users, :donor_id, false
  end
end
