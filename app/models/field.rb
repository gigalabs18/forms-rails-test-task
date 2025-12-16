class Field < ApplicationRecord
  belongs_to :form
  enum :field_type, { text: "text", number: "number", select: "select" }, prefix: :type

  has_many :options, dependent: :destroy
  has_many :responses, dependent: :destroy

  validates :label, presence: true
  validates :field_type, presence: true

  scope :ordered, -> { order(:id) }
end
