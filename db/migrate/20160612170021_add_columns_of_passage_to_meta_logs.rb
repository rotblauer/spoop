class AddColumnsOfPassageToMetaLogs < ActiveRecord::Migration
  def change
    add_column :meta_logs, :time_of_passage, :datetime, null: false
    add_column :meta_logs, :date_of_passage, :datetime, null: false
  end
end
