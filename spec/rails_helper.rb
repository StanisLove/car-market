require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "factory_bot_rails"
require "faker"
require "rspec/rails"
require "test_prof/recipes/rspec/let_it_be"
require "test_prof/recipes/rspec/any_fixture"
require "sidekiq/testing"
require "vcr"
require "webmock/rspec"
require "n_plus_one_control/rspec"
require "mock_redis"

Sidekiq::Testing.fake! # fake is the default mode

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

FactoryBot.reload

REDIS = MockRedis.new

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec::Matchers.define_negated_matcher :not_change, :change

VCR.configure do |config|
  config.cassette_library_dir = "#{::Rails.root}/spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

SidekiqUniqueJobs.configure do |config|
  config.enabled = !Rails.env.test?
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.include FactoryBot::Syntax::Methods
  FactoryBot.use_parent_strategy = false

  config.around(:each, inline: true) { |example| Sidekiq::Testing.inline!(&example) }
  config.before { Sidekiq::Worker.clear_all }

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end
