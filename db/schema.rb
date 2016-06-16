# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160616104947) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.json     "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
  add_index "ahoy_events", ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name", using: :btree
  add_index "ahoy_events", ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.string   "role"
    t.datetime "expires_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "donor_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "bristol_score"
    t.float    "weight"
    t.boolean  "donated"
    t.boolean  "processable"
    t.string   "notes"
    t.datetime "time_of_passage"
    t.datetime "date_of_passage"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_private",      default: true, null: false
    t.integer  "donor_number"
  end

  add_index "donor_logs", ["user_id"], name: "index_donor_logs_on_user_id", using: :btree

  create_table "meta_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "donor_log_id"
    t.integer  "open_biome_log_id"
    t.datetime "time_of_passage",   null: false
    t.datetime "date_of_passage",   null: false
  end

  add_index "meta_logs", ["donor_log_id"], name: "index_meta_logs_on_donor_log_id", using: :btree
  add_index "meta_logs", ["open_biome_log_id"], name: "index_meta_logs_on_open_biome_log_id", using: :btree
  add_index "meta_logs", ["user_id"], name: "index_meta_logs_on_user_id", using: :btree

  create_table "non_donors", force: :cascade do |t|
    t.string   "email"
    t.string   "message"
    t.boolean  "newsletter_ok"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "non_donors", ["email"], name: "index_non_donors_on_email", unique: true, using: :btree

  create_table "open_biome_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "donor_group"
    t.integer  "donor_number"
    t.string   "sample"
    t.string   "quarantine_state"
    t.string   "product"
    t.string   "usage"
    t.string   "processing_state"
    t.float    "weight"
    t.integer  "bristol_score"
    t.string   "batch"
    t.integer  "bio_safety_cabinet_number"
    t.float    "buffer_multiplier_used"
    t.integer  "number_units_produced"
    t.string   "on_site_donation"
    t.string   "received_by_name"
    t.string   "processed_by_name"
    t.datetime "time_of_passage"
    t.datetime "time_received"
    t.datetime "time_started"
    t.datetime "time_finished"
    t.string   "rejection_reason"
    t.string   "rejection_reason_other"
    t.integer  "biologics_master_file_version_number"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "donated_on"
  end

  add_index "open_biome_logs", ["user_id"], name: "index_open_biome_logs_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "donor_id",                                          null: false
    t.string   "role"
    t.string   "name"
    t.datetime "donor_since"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                   default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "donor_logs_are_private_by_default", default: true,  null: false
    t.boolean  "read_the_fine_print",               default: false, null: false
    t.boolean  "demo",                              default: false, null: false
    t.string   "admin_secret"
    t.string   "group"
    t.string   "encrypted_email",                   default: "",    null: false
    t.string   "encrypted_email_iv",                default: "",    null: false
    t.string   "liame"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["donor_id"], name: "index_users_on_donor_id", unique: true, using: :btree
  add_index "users", ["encrypted_email"], name: "index_users_on_encrypted_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree
  add_index "visits", ["visit_token"], name: "index_visits_on_visit_token", unique: true, using: :btree

  add_foreign_key "api_keys", "users"
  add_foreign_key "donor_logs", "users"
  add_foreign_key "meta_logs", "donor_logs"
  add_foreign_key "meta_logs", "open_biome_logs"
  add_foreign_key "meta_logs", "users"
  add_foreign_key "open_biome_logs", "users"
end
