class MigrateEmails < ActiveRecord::Migration
  def change
  	User.all.each do |u|
  		u.update_attributes(email: u.liame)
  	end

  	remove_column :users, :liame
  end
end
