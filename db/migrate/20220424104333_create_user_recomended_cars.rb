class CreateUserRecomendedCars < ActiveRecord::Migration[6.1]
  def change
    create_table :user_recommended_cars do |t|
      t.references :car, foreign_key: {on_delete: :cascade}, null: false
      t.references :user, foreign_key: {on_delete: :cascade}, null: false
      t.float :rank_score, null: false

      t.timestamps
    end
  end
end
