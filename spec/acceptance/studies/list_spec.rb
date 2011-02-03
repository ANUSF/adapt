require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "List", %q{
  In order to manage multiple studies I am preparing for submission
  As a contributor
  I want to view a list of my unsubmitted deposits
} do

  background do
    create_user 'Alice'
    create_user 'Bill'
    create_study 'First Study',  :owner => 'Alice'
    create_study 'Second Study', :owner => 'Alice'
    create_study 'Advanced Ham', :owner => 'Bill'
  end

  scenario "Alice can see her deposits, but not Bill's" do
    login_as 'Alice'
    click_link 'View deposits'

    path_should_be '/adapt/studies'
    page_heading_should_be 'Deposits'
    page.should have_css("table tbody tr", :count => 2)
    #column_contents('Created by').should == 'Alice'
  end

  def path_should_be(path)
    URI.parse(current_url).path.should == path
  end

  def page_heading_should_be(text)
    page.should have_css "#content > h1, article > h1", :text => text
  end

  def column_contents(name)
    #t = tableish("table tr", "th,td")
    #(t.transpose)[t[0].index(name)].join('"')
  end
end
