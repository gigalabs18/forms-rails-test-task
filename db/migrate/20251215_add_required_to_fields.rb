class AddRequiredToFields < ActiveRecord::Migration[8.0]
  def change
    add_column :fields, :required, :boolean, default: false, null: false
  end
end
