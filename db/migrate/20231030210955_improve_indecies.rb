class ImproveIndecies < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    change_column :cars, :price, "numeric USING CAST(price AS numeric)"
    change_column :cars, :price, :decimal, precision: 9, scale: 2
    add_index :cars, :price, algorithm: :concurrently
    add_check_constraint :cars, "price > 0", name: "cars_positive_price"

    remove_index :user_preferred_brands, :user_id
    add_index :user_preferred_brands, [:user_id, :brand_id], unique: true, algorithm: :concurrently

    add_index :users, 'TRIM(BOTH FROM LOWER(email))',
      unique: true,
      name: 'users_email_unique_idx',
      algorithm: :concurrently

    add_index :brands, 'LOWER(name)',
      unique: true,
      name: 'brands_name_unique_idx',
      algorithm: :concurrently

  end
end
