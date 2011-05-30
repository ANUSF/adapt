require 'simplecov'
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
end

class OpenidClient::SessionsController
  def new
    resource_class = resource_name.to_s.classify.constantize
    resource = resource_class.find_or_create_by_identity_url(params[:user])

    session[:openid_checked] = true
    set_flash_message :notice, :signed_in
    sign_in_and_redirect(resource_name, resource)
  end

  def destroy
    if signed_in?(resource_name)
      sign_out(resource_name)
      set_flash_message :notice, :signed_out
    end
    
    if (params[resource_name] || {})[:immediate]
      session[:openid_checked] = true
    end
    redirect_to root_url
  end
end
