# frozen_string_literal: true

module ReadModels
  class RefreshCarSuggestions
    def initialize(user_id)
      @user = User.find(user_id)
      @ai_recommendations = AiRecommendations::Storage.get(user_id)
    end

    def call
      ApplicationRecord.transaction do
        CarSuggestion.where(user: @user).delete_all
        insert(perfect_matches)
        insert(good_matches)
        upsert_ranks
      end
    end

    private

    def insert(cars)
      ApplicationRecord.connection.execute(<<~SQL)
        INSERT INTO #{CarSuggestion.table_name}
        (label, user_id, car_id)
        #{cars.select("#{@user.id}, cars.id").to_sql}
      SQL
    end

    def perfect_matches
      Car.perfect_matches(@user).select("0 AS label")
    end

    def good_matches
      Car.good_matches(@user).select("1 AS label")
    end

    def upsert_ranks
      return if @ai_recommendations.empty?

      CarSuggestion.upsert_all(
        @ai_recommendations.map { _1.merge(user_id: @user.id) },
        unique_by: :car_suggestions_unique_idx
      )
    end
  end
end
