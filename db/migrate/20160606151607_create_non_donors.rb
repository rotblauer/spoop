class CreateNonDonors < ActiveRecord::Migration
  def change
    create_table :non_donors do |t|
      t.string :email
      t.string :message
      t.boolean :newsletter_ok

      t.timestamps null: false
    end
    add_index :non_donors, :email, unique: true
  end
end
