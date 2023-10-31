require "rails_helper"

describe ReadModels::RefreshCarSuggestions do
  subject { described_class.new(user.id).call }

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


  context "without ai suggestions" do
    it "creates read model data" do
      expect { subject }.to change(CarSuggestion, :count).by(5)
      expect(CarSuggestion.where(user: user).pluck(:car_id, :label, :rank_score)).to contain_exactly(
        [perf_car1.id, "perfect_match", nil],
        [perf_car2.id, "perfect_match", nil],
        [perf_car3.id, "perfect_match", nil],
        [good_car1.id, "good_match", nil],
        [good_car2.id, "good_match", nil]
      )
    end
  end

  context "with ai suggestions" do
    before {
      AiRecommendations::Storage.put(
        user.id,
        [{car_id: perf_car1.id, rank_score: 0.9}, {car_id: other_car2.id, rank_score: 0.8}]
      )
    }

    after { REDIS.flushdb }

    it "creates read model data with rank score" do
      expect { subject }.to change(CarSuggestion, :count).by(6)
      expect(CarSuggestion.where(user: user).pluck(:car_id, :label, :rank_score)).to contain_exactly(
        [perf_car1.id, "perfect_match", 0.9],
        [perf_car2.id, "perfect_match", nil],
        [perf_car3.id, "perfect_match", nil],
        [good_car1.id, "good_match", nil],
        [good_car2.id, "good_match", nil],
        [other_car2.id, nil, 0.8]
      )
    end
  end
end
