# frozen_string_literal: true

class SuggestionsController < ApplicationController
  def index
    @pagy, @cars = pagy(UserCarsSuggestionsQuery.new(user).call(filters))
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def filters
    permitted_params.slice(:query, :price_min, :price_max)
  end

  # TODO: respond with 422 if not success
  def permitted_params
    result = schema.call(params.to_unsafe_hash)
    result.success? ? result.to_h : {}
  end

  def schema
    @schema ||= Dry::Schema.Params do
      required(:user_id).value(:integer)
      optional(:query).maybe(:string)
      optional(:price_min).maybe(:float)
      optional(:price_max).maybe(:float)
      optional(:page).value(:integer, gteq?: 1)
    end
  end
end
