# frozen_string_literal: true

class CreateVerdicts < ActiveRecord::Migration[8.1]
  def change
    create_table :verdicts do |t|
      t.references :submission, null: false, foreign_key: true
      t.integer :display_index
      t.string :grading_status
      t.integer :time_used
      t.integer :score

      t.timestamps
    end
  end
end
