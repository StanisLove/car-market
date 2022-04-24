# frozen_string_literal: true

class ExternalRequest
  NETWORK_EXCEPTIONS = [
    ::Faraday::ConnectionFailed,
    ::Net::ReadTimeout,
    ::Timeout::Error,
    ::Faraday::TimeoutError
  ].freeze

  class Response < SimpleDelegator
    alias_method :object, :__getobj__

    def as_json
      JSON.parse(object.body)
    end
  end

  attr_reader :response

  def initialize(endpoint:, query_params: {}, method: :get)
    @endpoint, @query_params, @method = endpoint, query_params, method
  end

  def call
    @response = Response.new(
      connection.run_request(method, endpoint, nil, nil) do |request|
        request.params.update(query_params)
      end
    )
  end

  private

  attr_reader :endpoint, :query_params, :method

  def connection
    @connection ||= Faraday.new do |conn|
      conn.options[:open_timeout] = 3
      conn.options[:timeout] = 10
      conn.request :retry, max: 5, exceptions: NETWORK_EXCEPTIONS
      conn.adapter Faraday.default_adapter
    end
  end
end
