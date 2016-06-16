class AddEmailToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :email, :string
  	add_index :users, :email, unique: true

  	User.all.each do |user|
  		user.update_column(:email, user.liame)
  	end
  end
end
