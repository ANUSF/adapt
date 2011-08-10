require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Re-authentication", %q{
  In order to not have to log in separately for each application
  As a user
  I want the system to synchronise my authentication data.
} do


  shared_examples_for "Adapt" do
    scenario "She can visit the study index page." do
      invalidate_authentication_state if @with_re_authentication
      visit "/adapt/studies"
      path_should_be "/adapt/studies"
    end

    scenario "She can visit the study edit page." do
      edit_page = study_edit_page_for 'First Study'
      invalidate_authentication_state if @with_re_authentication
      visit edit_page
      path_should_be edit_page
      page_heading_should_be 'Edit Study'
    end

    scenario "Study editing works properly." do
      edit_page = study_edit_page_for 'First Study'
      visit edit_page
      invalidate_authentication_state if @with_re_authentication
      click_button 'Apply'
      path_should_be edit_page
      page_heading_should_be 'Edit Study'
    end
  end


  background do
    create_user 'Alice'
    create_study 'First Study', :owner => 'Alice'
  end

  context "Alice is logged in." do
    background do
      login_as 'Alice'
    end

    context "The authentication state is still valid." do
      background do
        @with_re_authentication = false
      end
 
      it_should_behave_like 'Adapt'
   end

    context "The authentication state is outdated." do
      background do
        @with_re_authentication = true
      end

      it_should_behave_like 'Adapt'
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
