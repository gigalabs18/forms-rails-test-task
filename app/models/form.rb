class Form < ApplicationRecord
	has_many :fields, dependent: :destroy
	has_many :submissions, dependent: :destroy

	validates :title, presence: true
end
