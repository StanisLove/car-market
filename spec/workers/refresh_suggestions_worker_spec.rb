require "rails_helper"

describe RefreshSuggestionsWorker do
  subject { described_class.perform_async }

  let_it_be(:user1) { create :user }
  let_it_be(:user2) { create :user }
  let_it_be(:brand) { create :brand }
  let_it_be(:car1) { create :car, id: 179, brand: brand }
  let_it_be(:car2) { create :car, id: 5, brand: brand }
  let_it_be(:car3) { create :car, id: 13, brand: brand }
  let_it_be(:car4) { create :car, id: 97, brand: brand }

  let(:endpoint) { "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json" }

  before do
    ENV["AI_ENDPOINT"] = endpoint
    travel_to Time.current.midnight
  end

  after do
    ENV["AI_ENDPOINT"] = ""
    travel_back
  end

  it "stores ai recommendations for users", :inline do
    VCR.use_cassette(
      "car_recommendations",
      match_requests_on: [:method, VCR.request_matchers.uri_without_param(:user_id)],
      allow_playback_repeats: true
    ) do
      subject
      expect(AiRecommendations::Storage.get(user1.id).size).to eq(4)
      expect(AiRecommendations::Storage.get(user2.id).size).to eq(4)
    end
  end

  it "populates store model", :inline do
    VCR.use_cassette(
      "car_recommendations",
      match_requests_on: [:method, VCR.request_matchers.uri_without_param(:user_id)],
      allow_playback_repeats: true
    ) do
      expect { subject }.to change(CarSuggestion, :count).by(8)
      expect(CarSuggestion.pluck(:user_id, :car_id, :label, :rank_score)).to contain_exactly(
        [user1.id, car1.id, nil, 0.945],
        [user1.id, car2.id, nil, 0.4552],
        [user1.id, car3.id, nil, 0.567],
        [user1.id, car4.id, nil, 0.9489],
        [user2.id, car1.id, nil, 0.945],
        [user2.id, car2.id, nil, 0.4552],
        [user2.id, car3.id, nil, 0.567],
        [user2.id, car4.id, nil, 0.9489]
      )
    end
  end
end
