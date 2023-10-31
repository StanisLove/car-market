# frozen_string_literal: true
labels = CarSuggestion.labels.invert

json.(@cars) do |car|
  json.(car, :id, :price, :model, :rank_score)
  json.label labels[car.label]
  json.brand do
    json.id(car.brand_id)
    json.name(car.brand_name)
  end
end
