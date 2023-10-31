# frozen_string_literal: true

class RefreshSuggestionsWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_expired, lock_ttl: 1.day, on_confict: :log

  def perform
    User.select(:id).find_each do |user|
      RefreshUserSuggestionsWorker.perform_async(user.id)
    end
  end
end
