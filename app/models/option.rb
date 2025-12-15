class Option < ApplicationRecord
  belongs_to :field
  validates :label, presence: true
  validates :value, presence: true
end
