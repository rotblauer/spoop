ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# include Api
class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Improved Minitest output (color and progress bar)
  require "minitest/reporters"
  # Minitest::Reporters.use!(
  #   Minitest::Reporters::ProgressReporter.new,
  #   ENV,
  #   Minitest.backtrace_filter)
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

  include Devise::TestHelpers

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
      post login_path, session: { email:       user.email,
                                  password:    password,
                                  remember_me: remember_me }
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
