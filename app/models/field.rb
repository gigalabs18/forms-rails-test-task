class Field < ApplicationRecord
  belongs_to :form
  FIELD_TYPES = %w[text number select].freeze

  has_many :options, dependent: :destroy
  has_many :responses, dependent: :destroy

  validates :label, presence: true
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }

  scope :ordered, -> { order(:id) }

  def select?
    field_type == 'select'
  end
end
