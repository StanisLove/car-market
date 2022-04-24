require "rails_helper"

describe AiRecommendations do
  subject(:call) { described_class.new(user.id).call }

  let_it_be(:user) { create :user }
  let_it_be(:brand) { create :brand }
  let_it_be(:car1) { create :car, brand: brand }
  let_it_be(:car2) { create :car, brand: brand }

  let(:recommended_cars) { [] }
  let(:request) { instance_double("ExternalRequest") }
  let(:cached_cars) { described_class::Storage.get(user.id) }

  before do
    ENV["AI_ENDPOINT"] = endpoint
    allow(ExternalRequest).to receive(:new).and_return(request)
    allow(request).to receive(:call)
    response = instance_double("ExternalRequest::Response")
    allow(request).to receive(:response).and_return(response)
    allow(response).to receive(:as_json).and_return(
      recommended_cars.is_a?(Hash) ? recommended_cars.map(&:stringify_keys) : recommended_cars
    )
  end

  after {
    ENV["AI_ENDPOINT"] = ""
    REDIS.flushdb # TODO: move it to helper
  }

  context "without endpoint" do
    let(:endpoint) { "" }

    it "doesn't make a request" do
      expect(request).not_to receive(:call)
      call
    end
  end

  context "with endpoint" do
    let(:endpoint) { "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json" }

    it "makes a request" do
      expect(request).to receive(:call).once
      call
    end

    context "with empty response" do
      let(:recommended_cars) { [] }

      it "stores empty result" do
        call
        expect(cached_cars.size).to eq 0
      end
    end

    context "with data" do
      let(:recommended_cars) do
        [
          {car_id: car1.id, rank_score: 0.9},
          {car_id: car2.id, rank_score: 0.8}
        ]
      end

      it "stores recommended cars" do
        call
        expect(cached_cars.size).to eq 2
        rec1, rec2 = cached_cars
        expect(rec1).to eq(car_id: car1.id, rank_score: 0.9)
        expect(rec2).to eq(car_id: car2.id, rank_score: 0.8)
      end
    end

    context "with duplictions" do
      let(:recommended_cars) do
        [
          {car_id: car1.id, rank_score: 0.9},
          {car_id: car1.id, rank_score: 0.8}
        ]
      end

      it "stores the highest rank" do
        call
        expect(cached_cars.size).to eq 1
        expect(cached_cars.last).to eq(car_id: car1.id, rank_score: 0.9)
      end
    end

    context "when response isn't an array" do
      let(:recommended_cars) { "foo" }

      specify do
        expect { call }.to raise_error described_class::BadResponseError
      end
    end

    context "when response has invalid schema" do
      let(:recommended_cars) do
        [
          {car_id: car1.id, rank_score: 0.9},
          {cars_id: car2.id, rank_score: 0.8}
        ]
      end

      it "stores correct recommendations" do
        call
        expect(cached_cars.size).to eq 1
        expect(cached_cars.last).to eq(car_id: car1.id, rank_score: 0.9)
      end
    end

    context "when response has not existed car id" do
      let(:recommended_cars) do
        [
          {car_id: car1.id, rank_score: 0.9},
          {car_id: build_stubbed(:car).id, rank_score: 0.8}
        ]
      end

      it "stores correct recommendations" do
        call
        expect(cached_cars.size).to eq 1
        expect(cached_cars.last).to eq(car_id: car1.id, rank_score: 0.9)
      end
    end

    context "when response has negative rank" do
      let(:recommended_cars) do
        [
          {car_id: car1.id, rank_score: 0.9},
          {car_id: car2.id, rank_score: -0.8}
        ]
      end

      it "stores correct recommendations" do
        call
        expect(cached_cars.size).to eq 1
        expect(cached_cars.last).to eq(car_id: car1.id, rank_score: 0.9)
      end
    end
  end
end
