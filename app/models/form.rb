class Form < ApplicationRecord
  belongs_to :user, optional: true
  has_many :fields, dependent: :destroy
  has_many :submissions, dependent: :destroy

  validates :title, presence: true

  before_create :ensure_public_token

  def regenerate_public_token!
    update!(public_token: generate_unique_public_token)
  end

  def ensure_public_token
    self.public_token ||= generate_unique_public_token
  end

  private
    def generate_unique_public_token
      loop do
        token = SecureRandom.urlsafe_base64(10)
        break token unless Form.exists?(public_token: token)
      end
    end
end
