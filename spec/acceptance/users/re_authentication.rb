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

    context "The client state cookie is still valid" do

      scenario "She can visit the study index page" do
        visit "/adapt/studies"
        path_should_be "/adapt/studies"
        page.status_code.should == 200
      end
    end

    context "The client state cookie is expired" do

      background do
        key = OpenidClient::Config.client_state_key
        set_cookie key, ''
        get_cookie(key).should == ''
      end

      scenario "She can still visit the study index page" do
        visit "/adapt/studies"
        path_should_be "/adapt/studies"
      end
    end
  end

  def jar
    @jar ||= Capybara.current_session.driver.browser.rack_mock_session.cookie_jar
  end
  
  def set_cookie(key, value)
    jar.merge "#{key.to_s}=#{value};domain=www.example.com;path=/"
  end

  def get_cookie(key)
    jar[key.to_s]
  end
end
