class CreateMetaLogs < ActiveRecord::Migration
  def change
    create_table :meta_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :donor_log, index: true, foreign_key: true
      t.references :open_biome_log, index: true, foreign_key: true
    end
  end
end
