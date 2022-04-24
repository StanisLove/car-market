FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Brand name #{n}" }
  end
end

