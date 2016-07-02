source 'https://rubygems.org'
ruby "2.2.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc


gem 'activeresource'
gem "bower-rails", "~> 0.10.0"
# gem 'materialize-sass'
# gem 'bootstrap-sass', '~> 3.3.6'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'bootstrap', '~> 4.0.0.alpha3'
gem 'rails-assets-tether', '>= 1.1.0'
gem "font-awesome-rails"
gem 'faker'

gem 'lazy_high_charts'

gem 'chartkick'
gem 'groupdate'
gem 'hightop'
gem 'descriptive_statistics', '~> 2.4.0', :require => 'descriptive_statistics/safe'

# gem 'momentjs-rails', '>= 2.9.0'
# gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'

gem 'devise'
gem 'attr_encrypted'
gem 'token_phrase'

# For opening API. 
gem 'rack-cors', :require => 'rack/cors'
gem 'table_print'

# rails vars in js
gem 'gon'
gem "d3-rails"

gem 'ahoy_matey'
gem 'figaro'

gem 'acts-as-taggable-on', '~> 3.5'

gem 'roo'
gem 'time_zone_ext'

# heroku needs this to do logging right
# $ heroku logs -t --source app --remote web
gem 'rails_12factor', group: :production
gem 'query_diet', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'guard', ">=2.2.2", require: false
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'rack-livereload'
  gem 'rb-fsevent', require: false
  
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'seed_dump'
end

# Matt Brictson
# group :development do
#   gem "guard", ">= 2.2.2", :require => false
#   gem "guard-minitest", :require => false
#   gem "rb-fsevent", :require => false
#   gem "terminal-notifier-guard", :require => false
# end

group :test do
  # gem "capybara"
  gem 'minitest-rails-capybara'
  # gem 'minitest-capybara', '~> 0.8'
  # gem "connection_pool"
  # gem "launchy"
  gem "minitest-reporters"
  # gem "mocha"
  # gem "poltergeist"
  # gem "shoulda-context"
  # gem "shoulda-matchers", ">= 3.0.1"
  # gem "test_after_commit"
end







