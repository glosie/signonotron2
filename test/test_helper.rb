if ENV["USE_SIMPLECOV"]
  require "simplecov"
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'shoulda'
require "test/unit"
require "mocha/setup"
require 'webmock/test_unit'
require 'capybara/rails'

require 'helpers/user_helpers'
require 'helpers/email_helpers'

require 'sidekiq/testing'
Sidekiq::Testing.fake!

WebMock.disable_net_connect!(:allow_localhost => true)

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  teardown do
    WebMock.reset!
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include UserHelpers
  include EmailHelpers

  def assert_response_contains(content)
    assert page.has_content?(content), page.body
  end

  def assert_current_url(path_with_query, options = {})
    expected = URI.parse(path_with_query)
    current = URI.parse(current_url)
    assert_equal expected.path, current.path
    unless options[:ignore_query]
      assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(current.query)
    end
  end
end
