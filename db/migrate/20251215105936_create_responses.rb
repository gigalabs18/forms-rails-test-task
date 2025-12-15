class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
  end
end
