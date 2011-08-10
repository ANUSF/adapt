require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Re-authentication", %q{
  In order to not have to log in separately for each application
  As a user
  I want the system to synchronise my authentication data
} do

  background do
    create_user 'Alice'
  end

  context "Alice is logged in" do
    background do
      login_as 'Alice'
    end

    context "The authentication state is still valid" do

      scenario "She can visit the study index page" do
        visit "/adapt/studies"
        path_should_be "/adapt/studies"
        page.status_code.should == 200
      end
    end

    context "The authentication state is outdated" do

      background do
        invalidate_authentication_state
      end

      scenario "She can still visit the study index page" do
        visit "/adapt/studies"
        path_should_be "/adapt/studies"
      end
    end
  end


  def invalidate_authentication_state
    key = OpenidClient::Config.server_timestamp_key
    timestamp = Time.now.to_f.to_s
    set_cookie key, timestamp

    # Making sure the cookie got set correctly.
    get_cookie(key).should == timestamp
  end

  def set_cookie(key, value)
    # This is how one needs to set cookies in Rack::Test.
    jar.merge "#{key.to_s}=#{value};domain=#{domain};path=/"
  end

  def get_cookie(key)
    jar[key.to_s]
  end

  def jar
    # Sorry Selenium!
    driver = Capybara.current_session.driver
    driver.class.should == Capybara::RackTest::Driver

    @jar ||= driver.browser.rack_mock_session.cookie_jar
  end
  
  def domain
    @domain ||= current_host.sub /\A (?:https?:\/\/)? (.*) (?::\d+)? \z/x, '\\1'
  end
end
