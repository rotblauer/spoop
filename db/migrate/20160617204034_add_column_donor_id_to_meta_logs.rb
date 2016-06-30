class AddColumnDonorIdToMetaLogs < ActiveRecord::Migration
  def change
    add_column :meta_logs, :donor_id, :integer
    add_index :meta_logs, [:user_id, :donor_id]
  end
end
