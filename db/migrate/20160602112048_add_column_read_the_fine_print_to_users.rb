class AddColumnReadTheFinePrintToUsers < ActiveRecord::Migration
  def change
    add_column :users, :read_the_fine_print, :boolean, null: false, default: false
  end
end
