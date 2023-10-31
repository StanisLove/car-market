require "rails_helper"

describe UserCarsSuggestionsQuery do
  subject { described_class.new(user).call }

  let_it_be(:ar) { create :brand, name: "Alfa Romeo" }
  let_it_be(:vw) { create :brand, name: "Volkswagen" }
  let_it_be(:vaz) { create :brand, name: "VAZ" }

  let_it_be(:user) do
    create :user,
      preferred_price_range: 10_000..15_000,
      user_preferred_brands_attributes: [{brand_id: vw.id}, {brand_id: ar.id}]
  end
  # Perfect match
  let_it_be(:perf_car1) { create :car, brand: vw, model: "Golf", price: 10_000 }
  let_it_be(:perf_car2) { create :car, brand: vw, model: "Passat B1", price: 13_000 }
  let_it_be(:perf_car3) { create :car, brand: vw, model: "Passat CC", price: 15_000 }
  # Good match
  let_it_be(:good_car1) { create :car, brand: ar, model: "Giulia", price: 9_999.99 }
  let_it_be(:good_car2) { create :car, brand: ar, model: "Stelvio", price: 17_000 }
  # Other cars
  let_it_be(:other_car1) { create(:car, brand: vaz, model: "Niva", price: 5_000) }
  let_it_be(:other_car2) { create(:car, brand: vaz, model: "Largus", price: 7_000) }
  # AI suggestions
  (1..7).each do |n|
    let_it_be("ai_car#{n}") { create(:car, brand: vaz, model: "210#{n}", price: 9_000 / n) }
  end

  before {
    AiRecommendations::Storage.put(user.id, [
      {car_id: perf_car2.id, rank_score: 1},
      {car_id: perf_car3.id, rank_score: 0.2},
      {car_id: good_car2.id, rank_score: 0.5},
      {car_id: ai_car1.id, rank_score: 0.7},
      {car_id: ai_car2.id, rank_score: 0.6},
      {car_id: ai_car3.id, rank_score: 0.5},
      {car_id: ai_car4.id, rank_score: 0.4},
      {car_id: ai_car5.id, rank_score: 0.3},
      {car_id: ai_car6.id, rank_score: 0.1},
      {car_id: ai_car7.id, rank_score: 0.2},
    ])
  }

  after { REDIS.flushdb }

  context "when read model is populated" do
    before { ReadModels::RefreshCarSuggestions.new(user.id).call }

    specify do
      is_expected.to eq([
        perf_car2,
        perf_car3,
        perf_car1,
        good_car2,
        good_car1,
        ai_car1,
        ai_car2,
        ai_car3,
        ai_car4,
        ai_car5,
        ai_car7,
        ai_car6,
        other_car1,
        other_car2
      ])
    end
  end

  context "when read model is not populated" do
    it "still works and orders by price" do
      expect(subject.pluck(:price)).to eq([
        1285,
        1500,
        1800,
        2250,
        3000,
        4500,
        5000,
        7000,
        9000,
        9999.99,
        10000,
        13000,
        15000,
        17000
      ])
    end
  end
end
