class CreateDonorLogs < ActiveRecord::Migration
  def change
    create_table :donor_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :bristol_score
      t.float :weight
      t.boolean :donated
      t.boolean :processable
      t.string :notes
      t.datetime :time_of_passage
      t.datetime :date_of_passage

      t.timestamps null: false
    end
  end
end
