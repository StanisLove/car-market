# frozen_string_literal: true

class UserCarsSuggestionsQuery
  def initialize(user)
    @user = user
  end

  def call(query: nil, price_min: nil, price_max: nil)
    Car
      .joins(:brand)
      .joins(<<~SQL)
        LEFT JOIN car_suggestions AS cs ON cs.user_id = #{@user.id} AND cs.car_id = cars.id
      SQL
      .select(<<~SQL)
        cars.id,
        cars.price,
        cars.model,
        cars.brand_id,
        brands.name AS brand_name,
        cs.rank_score AS rank_score,
        cs.label
      SQL
      .order("cs.label ASC NULLS LAST, rank_score DESC NULLS LAST, price ASC")
      .then { |rel| filter_by_query(rel, query) }
      .then { |rel| filter_by_min_price(rel, price_min) }
      .then { |rel| filter_by_max_price(rel, price_max) }
  end

  private

  def filter_by_query(relation, query)
    return relation if query.blank?

    relation.where("brands.name ILIKE '%#{query}%'")
  end

  def filter_by_min_price(relation, price_min)
    return relation unless price_min.is_a?(Numeric)

    relation.where("price >= ?", price_min)
  end

  def filter_by_max_price(relation, price_max)
    return relation unless price_max.is_a?(Numeric)

    relation.where("price <= ?", price_max)
  end
end
