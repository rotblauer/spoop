ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Because Devise test helpers don't like capybara
class ActionController::TestCase
  include Devise::TestHelpers
end

## Clicky tests.
#
require "minitest/rails/capybara"

## CLI create a new capybara feature test 
# rails g minitest:feature InteractWithDonorLogs
# rake minitest:features

# https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
class Capybara::Rails::TestCase
  #   include Warden::Test::Helpers
  #   Warden.test_mode!
  
  def user
    users(:ob_donor)
  end
  def password(word='password')
    word
  end

  def do_sign_in(user, options={})
    visit root_path
    click_link 'Login'
    assert_content 'Log in'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: options[:password] || password
    # check 'Remember me'
    click_button 'Log in'

    assert_content page, "#{user.role.capitalize!} #{user.donor_id}"
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

## Integration tests.
#
class ActionDispatch::IntegrationTest
  # # Make the Capybara DSL available in all integration tests
  # include Capybara::DSL
  # # Reset sessions and driver between tests
  # # Use super wherever this method is redefined in your individual test classes
  # def teardown
  #   Capybara.reset_sessions!
  #   Capybara.use_default_driver
  # end
end

## Unit tests. 
#
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Improved Minitest output (color and progress bar)
  require "minitest/reporters"
  Minitest::Reporters.use!(
    Minitest::Reporters::SpecReporter.new,
    ENV,
    Minitest.backtrace_filter)
  # Minitest::Reporters::DefaultReporter  # => Redgreen-capable version of standard Minitest reporter
  # Minitest::Reporters::SpecReporter     # => Turn-like output that reads like a spec
  # Minitest::Reporters::ProgressReporter # => Fuubar-like output with a progress bar
  # Minitest::Reporters::RubyMateReporter # => Simple reporter designed for RubyMate
  # Minitest::Reporters::RubyMineReporter # => Reporter designed for RubyMine IDE and TeamCity CI server
  # Minitest::Reporters::JUnitReporter    # => JUnit test reporter designed for JetBrains TeamCity
  # Minitest::Reporters::MeanTimeReporter # => Produces a report summary showing the slowest running tests
  # Minitest::Reporters::HtmlReporter     # => Generates an HTML report of the test results
  
  def json(response_body)
    JSON.parse(response_body)
  end

  def path_at(url)
    URI.parse(url).path
  end

  # http://stackoverflow.com/questions/32168204/how-to-sign-in-for-devise-to-test-controller-with-minitest
  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def sign_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => password#, 'user[remember_me]' => remember_me
    else
      session[:user_id] = user.id
    end
  end

  private

  # Returns true inside an integration test.
  def integration_test?
    defined?(post_via_redirect)
  end
  
end
