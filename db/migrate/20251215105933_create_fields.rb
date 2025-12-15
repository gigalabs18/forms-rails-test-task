class CreateFields < ActiveRecord::Migration[8.0]
  def change
    create_table :fields do |t|
      t.references :form, null: false, foreign_key: true
      t.string :label
      t.string :field_type
      t.integer :position

      t.timestamps
    end
  end
end
