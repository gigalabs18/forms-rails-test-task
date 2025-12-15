class CreateOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :options do |t|
      t.references :field, null: false, foreign_key: true
      t.string :label
      t.string :value
      t.integer :position

      t.timestamps
    end
  end
end
