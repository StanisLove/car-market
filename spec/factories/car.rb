FactoryBot.define do
  factory :car do
    sequence(:model) { |n| "Model #{n}" }
    price { 100.0 }
  end
end

