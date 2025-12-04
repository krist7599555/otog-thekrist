# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :markdown
      t.string :grading_command

      t.timestamps
    end
  end
end
