# frozen_string_literal: true

class RefreshUserSuggestionsWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, on_confict: :log
  sidekiq_options retry: 20

  sidekiq_retry_in do |count, exception|
    case exception
    when AiRecommendations::BadResponseError
      1.hour * (count + 1)
    else
      10.minutes * (count + 1)
    end
  end

  def perform(user_id)
    AiRecommendations.new(user_id).call
    ReadModels::RefreshCarSuggestions.new(user_id).call
  end
end
