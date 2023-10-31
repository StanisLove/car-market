class Car < ApplicationRecord
  belongs_to :brand

  scope :perfect_matches, ->(user) {
    joins(:brand)
      .where(
        brands: {id: user.preferred_brands.ids},
        price: user.preferred_price_range
      )
  }
  scope :good_matches, ->(user) {
    joins(:brand)
      .where(brands: {id: user.preferred_brands.ids})
      .where.not(price: user.preferred_price_range)
  }
end
