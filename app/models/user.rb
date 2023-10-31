class User < ApplicationRecord
  has_many :user_preferred_brands, dependent: :destroy
  has_many :preferred_brands, through: :user_preferred_brands, source: :brand

  accepts_nested_attributes_for :user_preferred_brands

  # TODO: Refresh read model if preffered brands or price changed
end
