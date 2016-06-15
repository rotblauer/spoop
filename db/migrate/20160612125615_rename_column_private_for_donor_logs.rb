class RenameColumnPrivateForDonorLogs < ActiveRecord::Migration
  def change
  	rename_column :donor_logs, :private, :is_private
  end
end
