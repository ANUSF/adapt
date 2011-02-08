module HelperMethods
  # Put helper methods you need to be available in all tests here.

  def login_as(name)
    visit '/login'
    fill_in 'login', :with => name
    click_button 'Login via ASSDA'
  end

  def create_user(name, options = {})
    Adapt::User.make :name => name, :role => options[:role] || 'contributor'
  end

  def create_study(title, options = {})
    user = Adapt::User.find_by_name(options[:owner]) || Adapt::User.first
    Adapt::Study.make(:owner => user, :title => title)
  end

  def path_should_be(path)
    URI.parse(current_url).path.should == path
  end

  def page_heading_should_be(text)
    page.should have_css "#content > h1, article > h1", :text => text
  end

  def there_should_be_a_notice(text)
    page.should have_css "#flash_notice, .flash-notice", :text => text
  end

  def there_should_be_an_error_message(text)
    page.should have_css "#flash_error, .flash-error", :text => text
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
