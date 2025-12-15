class AddUserToForms < ActiveRecord::Migration[8.0]
  def change
    add_reference :forms, :user, null: true, foreign_key: true
  end
end
