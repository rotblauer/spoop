class ChangeColumnToDatetimesInOpenBiomeLogs < ActiveRecord::Migration
  def change
    remove_column :open_biome_logs, :donated_on
    add_column :open_biome_logs, :donated_on, :datetime
  end
end
