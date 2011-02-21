RSpec.configure do |config|
  javascript_driver = defined?(JRUBY_VERSION) ? :celerity : :selenium

  config.filter_run :js_advanced => lambda { |val|
    !val or defined?(JRUBY_VERSION)
  }

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    if example.metadata[:js]
      Capybara.current_driver = javascript_driver
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
    DatabaseCleaner.clean
  end
end
