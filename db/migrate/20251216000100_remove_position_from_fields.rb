class RemovePositionFromFields < ActiveRecord::Migration[7.1]
  def change
    remove_column :fields, :position, :integer
  end
end
