class AndDropLiame < ActiveRecord::Migration
  def change
  	remove_column :users, :liame
  end
end
