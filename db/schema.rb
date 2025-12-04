# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 20_251_204_105_615) do
  create_table 'active_storage_attachments', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.string 'name', null: false
    t.bigint 'record_id', null: false
    t.string 'record_type', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.string 'content_type'
    t.datetime 'created_at', null: false
    t.string 'filename', null: false
    t.string 'key', null: false
    t.text 'metadata'
    t.string 'service_name', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'submissions', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'grading_detail'
    t.string 'grading_status'
    t.string 'lang'
    t.integer 'score'
    t.text 'source_code'
    t.integer 'task_id', null: false
    t.integer 'time_used'
    t.datetime 'updated_at', null: false
    t.integer 'user_id', null: false
    t.index ['task_id'], name: 'index_submissions_on_task_id'
    t.index ['user_id'], name: 'index_submissions_on_user_id'
  end

  create_table 'tasks', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'grading_command'
    t.text 'markdown'
    t.string 'name'
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'display_name'
    t.string 'name'
    t.datetime 'updated_at', null: false
  end

  create_table 'verdicts', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.integer 'display_index'
    t.string 'grading_status'
    t.integer 'score'
    t.integer 'submission_id', null: false
    t.integer 'time_used'
    t.datetime 'updated_at', null: false
    t.index ['submission_id'], name: 'index_verdicts_on_submission_id'
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'submissions', 'tasks'
  add_foreign_key 'submissions', 'users'
  add_foreign_key 'verdicts', 'submissions'
end
