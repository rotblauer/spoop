class AddColumnAdminSecretToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin_secret, :string
  end
end
