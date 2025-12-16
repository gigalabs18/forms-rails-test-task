class Response < ApplicationRecord
  belongs_to :submission
  belongs_to :field
  # Validation for presence is handled by the SubmissionsController based on Field#required
end
