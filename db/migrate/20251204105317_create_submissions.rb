# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.text :source_code
      t.string :lang
      t.string :grading_status
      t.string :grading_detail
      t.integer :time_used
      t.integer :score

      t.timestamps
    end
  end
end
