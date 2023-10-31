source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3', '>= 6.1.3.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
gem "dotenv-rails"
gem "faraday"
gem "faraday-retry"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "sidekiq-unique-jobs"
gem "dry-schema"
gem "rswag-api"
gem "rswag-ui"
gem "pagy"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem "pry-byebug"
  gem "pry-rescue"
  gem "pry-stack_explorer"
end

group :development do
  gem 'listen', '~> 3.3'
  gem "pry-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "database_cleaner"
  gem "fuubar"
  gem "json_spec"
  gem "mock_redis"
  gem "n_plus_one_control"
  gem "rspec-rails"
  gem "rswag-specs"
  gem "shoulda-matchers"
  gem "test-prof"
  gem "webmock"
  gem "vcr"
end
