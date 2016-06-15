class RenameColumnAccessToken < ActiveRecord::Migration
  def change
  	rename_column :api_keys, :token, :access_token
  end
end
