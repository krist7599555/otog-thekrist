# frozen_string_literal: true

class Task < ApplicationRecord
  has_one_attached :pdf
  has_many_attached :files
  has_many :submission
end
