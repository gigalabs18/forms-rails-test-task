class Response < ApplicationRecord
  belongs_to :submission
  belongs_to :field
  validates :value, presence: true, allow_blank: true
end
