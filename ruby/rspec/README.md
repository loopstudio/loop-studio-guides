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

Support folder created to use json_matchers, for example:
```ruby
 it { is_expected.to match_response_schema('users/index') }
```closing backticks
