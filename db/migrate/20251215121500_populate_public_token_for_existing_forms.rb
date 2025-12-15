class PopulatePublicTokenForExistingForms < ActiveRecord::Migration[8.0]
  def up
    say_with_time "Generating public tokens for existing forms" do
      Form.reset_column_information
      Form.where(public_token: nil).find_each do |f|
        f.update_columns(public_token: gen_token)
      end
    end
  end

  def down
    # no-op
  end

  private
  def gen_token
    loop do
      token = SecureRandom.urlsafe_base64(10)
      break token unless Form.exists?(public_token: token)
    end
  end
end
