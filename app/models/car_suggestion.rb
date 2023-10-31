# frozen_string_literal: true

class CarSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :car

  enum label: {
    perfect_match: 0,
    good_match: 1
  }
end
