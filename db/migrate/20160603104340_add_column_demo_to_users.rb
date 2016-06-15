class AddColumnDemoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :demo, :boolean, default: false, null: false
  end
end
