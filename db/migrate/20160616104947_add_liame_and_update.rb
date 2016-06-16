class AddLiameAndUpdate < ActiveRecord::Migration
  def change
  	add_column :users, :liame, :string 

  	User.all.each do |user|
  		e = user.email
  		puts "#{e}"
  		user.update_column(:liame, e) if e.present?
  	end
  end
end
