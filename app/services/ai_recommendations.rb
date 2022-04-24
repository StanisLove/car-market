# frozen_string_literal: true

class AiRecommendations
  BadResponseError = Class.new(StandardError)
  Storage = Class.new do
    def self.get(user_id)
      recommendations = REDIS.hget("ai", user_id)
      return [] if recommendations.blank?

      JSON.parse(recommendations).map(&:symbolize_keys)
    end

    def self.put(user_id, recommendations)
      return if recommendations.blank?

      REDIS.hset("ai", {user_id => recommendations.to_json})
    end
  end

  def initialize(user_id)
    @user_id = user_id
    @endpoint = ENV["AI_ENDPOINT"]
  end

  # TODO: Clarify logic for edge cases
  # - When response is not an array
  # - When response contains elements with unexpected format
  # - When response contains elements with negative rank
  # - When response contains elements with not existed car id
  def call
    return if @endpoint.blank?

    raise BadResponseError unless recommendations.is_a?(Array)

    Storage.put(@user_id, prepared_recommendations)
  end

  private

  def recommendations
    @recommendations ||= begin
      request = ExternalRequest.new(endpoint: @endpoint, query_params: {user_id: @user_id})
      request.call
      request.response.as_json
    end
  end

  def prepared_recommendations
    recommendations.filter_map { |rec|
      result = schema.call(rec)
      result.to_h if result.success?
    }.sort_by { |rec| rec[:rank_score] }.reverse.uniq { |rec| rec[:car_id] }
  end

  def schema
    Dry::Schema.Params do
      # TODO: Cache car ids
      required(:car_id).value(included_in?: Car.pluck(:id))
      required(:rank_score).value(:float, gteq?: 0)
    end
  end
end
