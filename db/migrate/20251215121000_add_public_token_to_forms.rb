class AddPublicTokenToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :public_token, :string
    add_index :forms, :public_token, unique: true
  end
end
