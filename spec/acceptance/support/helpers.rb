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
end

RSpec.configuration.include HelperMethods, :type => :acceptance
