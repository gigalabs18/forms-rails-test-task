class Submission < ApplicationRecord
  belongs_to :form
  has_many :responses, dependent: :destroy
end
