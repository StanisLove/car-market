require "swagger_helper"

describe "Car suggestions" do
  let(:user_id) { user.id }

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
  let_it_be(:perf_car12) { create :car, brand: vw, model: "Golf", price: 10_000 }
  let_it_be(:perf_car22) { create :car, brand: vw, model: "Passat B1", price: 13_000 }
  let_it_be(:perf_car33) { create :car, brand: vw, model: "Passat CC", price: 15_000 }
  let_it_be(:perf_car13) { create :car, brand: vw, model: "Golf", price: 10_000 }
  let_it_be(:perf_car23) { create :car, brand: vw, model: "Passat B1", price: 13_000 }
  let_it_be(:perf_car33) { create :car, brand: vw, model: "Passat CC", price: 15_000 }
  # Good match
  let_it_be(:good_car1) { create :car, brand: ar, model: "Giulia", price: 9_999.99 }
  let_it_be(:good_car2) { create :car, brand: ar, model: "Stelvio", price: 17_000 }
  let_it_be(:good_car11) { create :car, brand: ar, model: "Giulia", price: 9_999.99 }
  let_it_be(:good_car21) { create :car, brand: ar, model: "Stelvio", price: 17_000 }
  let_it_be(:good_car12) { create :car, brand: ar, model: "Giulia", price: 9_999.99 }
  let_it_be(:good_car22) { create :car, brand: ar, model: "Stelvio", price: 17_000 }
  let_it_be(:good_car13) { create :car, brand: ar, model: "Giulia", price: 9_999.99 }
  let_it_be(:good_car23) { create :car, brand: ar, model: "Stelvio", price: 17_000 }
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
    ReadModels::RefreshCarSuggestions.new(user.id).call
  }

  path "/suggestions" do
    get "Get car suggestions" do
      tags "Cars"
      consumes "application/json"
      produces "application/json"

      parameter name: :user_id, in: :query, description: "user id", required: true
      parameter name: :query, in: :query, description: "car brand name or part of car brand name to filter by", required: false
      parameter name: :price_min, in: :query, description: "minimum price", required: false
      parameter name: :price_max, in: :query, description: "minimum price", required: false
      parameter name: :page, in: :query, description: "page number", required: false

      response 200, "Success" do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: {type: :integer},
            price: {type: :float},
            rank_score: {type: :float, nullable: true},
            model: {type: :string},
            label: {type: :string, enum: %w[perfect_match good_match].push(nil), nullable: true},
            brand: {
              type: :object,
              properties: {
                id: {type: :integer},
                name: {type: :string}
              },
              required: %i[id name],
              additionalProperties: false
            }
          },
          required: %i[id price rank_score model label brand],
          additionalProperties: false
        }

        context "without params" do
          run_test! do
            expect(response.body).to have_json_size(20)
          end
        end

        context "with page" do
          let(:page) { 2 }

          run_test! do
            expect(response.body).to have_json_size(6)
          end
        end

        context "with query" do
          let(:query) { "OLKSWA" }

          run_test! do
            expect(response.body).to have_json_size(9)
            expect(JSON.parse(response.body).pluck("brand").pluck("name").uniq).to eq ["Volkswagen"]
          end
        end

        context "with min and max price" do
          let(:price_min) { 5_000 }
          let(:price_max) { 7_000 }

          run_test! do
            expect(response.body).to have_json_size(2)
          end
        end
      end
    end
  end
end
