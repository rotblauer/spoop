class AddLiameAgain < ActiveRecord::Migration
  def change
  	add_column :users, :liame, :string

  	User.all.each do |u|
  		e = u.email
  		u.update_attribute(:liame, e)
  	end
  end
end
