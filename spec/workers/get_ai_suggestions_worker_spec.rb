require "rails_helper"

describe GetAiSuggestionsWorker do
  subject { described_class.perform_async }

  let_it_be(:user1) { create :user }
  let_it_be(:user2) { create :user }

  before do
    brand = create(:brand)
    [179, 5, 13, 97].each { |id| create :car, id: id, brand: brand }
  end

  let(:endpoint) { "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json" }

  before do
    ENV["AI_ENDPOINT"] = endpoint
    travel_to Time.current.midnight
  end

  after do
    ENV["AI_ENDPOINT"] = ""
    travel_back
  end

  it "creates recommendations for users", :inline do
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
end
