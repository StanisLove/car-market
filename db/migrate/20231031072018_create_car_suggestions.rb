class CreateCarSuggestions < ActiveRecord::Migration[6.1]
  def change
    create_table :car_suggestions do |t|
      t.references :car, foreign_key: {on_delete: :cascade}, null: false
      t.references :user, foreign_key: {on_delete: :cascade}, index: false, null: false
      t.float :rank_score, index: true
      t.integer :label
    end

    add_index :car_suggestions, [:user_id, :car_id], unique: true, name: :car_suggestions_unique_idx
  end
end
