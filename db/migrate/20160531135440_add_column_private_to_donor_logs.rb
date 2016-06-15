class AddColumnPrivateToDonorLogs < ActiveRecord::Migration
  def change
    add_column :donor_logs, :private, :boolean, default: true, null: false
    add_column :users, :donor_logs_are_private_by_default, :boolean, default: true, null: false
  end
end
