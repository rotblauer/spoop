class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.references :user, index: true, foreign_key: true
      t.string :token
      t.string :role
      t.datetime :expires_at

      t.timestamps null: false
    end
  end
end
