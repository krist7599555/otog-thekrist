# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :task
  accepts_nested_attributes_for :user, :task
  validates :user, presence: true
  validates :task, presence: true
end
