class AddColumnDonorNumberToDonorLogs < ActiveRecord::Migration
  def change
    add_column :donor_logs, :donor_number, :integer

    DonorLog.all.each do |log|
    	log.update_attributes(donor_number: log.user.donor_id)
 		end
 		
  end
end
