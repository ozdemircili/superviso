require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.fail_fast = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  config.use_transactional_fixtures = false
  
  #For test with Devise
  include Warden::Test::Helpers
  Warden.test_mode!

  config.after :each do
    Warden.test_reset! 
  end
  config.include Devise::TestHelpers, :type => :controller
end

Capybara.javascript_driver = :webkit
WebMock.disable_net_connect!(allow_localhost: true)
