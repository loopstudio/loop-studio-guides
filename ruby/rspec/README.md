gems used:

group :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'json_matchers', '0.9.0'
  gem 'rspec-json_expectations'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
end

support folder created to use json_matchers, for example: it { is_expected.to           match_response_schema('users/index') }
