class CreateOpenBiomeLogs < ActiveRecord::Migration
  def change
    create_table :open_biome_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :donated_on
      t.string :donor_group
      t.integer :donor_number
      t.string :sample
      t.string :quarantine_state
      t.string :product
      t.string :usage
      t.string :processing_state
      t.float :weight
      t.integer :bristol_score
      t.string :batch
      t.integer :bio_safety_cabinet_number
      t.float :buffer_multiplier_used
      t.integer :number_units_produced
      t.string :on_site_donation
      t.string :received_by_name
      t.string :processed_by_name
      t.datetime :time_of_passage
      t.datetime :time_received
      t.datetime :time_started
      t.datetime :time_finished
      t.string :rejection_reason
      t.string :rejection_reason_other
      t.integer :biologics_master_file_version_number

      t.timestamps null: false
    end
  end
end
