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

  shared_examples_for "on the study index page" do
    path_should_be '/adapt/studies'
    page_heading_should_be 'Deposits'
  end

  scenario "Alice can see her deposits, but not Bill's" do
    login_as 'Alice'
    click_link 'View deposits'

    path_should_be '/adapt/studies'
    page_heading_should_be 'Deposits'
    page.should have_css("table tbody tr", :count => 2)

    creators = column_contents 'Created by'
    creators.should include 'Alice'
    creators.should_not include 'Bill'

    titles = column_contents 'Title'
    titles.should include 'First Study'
    titles.should include 'Second Study'
    titles.should_not include 'Advanced Ham'
  end

  scenario "Bill can see his deposits, but not Alice's" do
    login_as 'Bill'
    click_link 'View deposits'

    path_should_be '/adapt/studies'
    page_heading_should_be 'Deposits'
    page.should have_css("table tbody tr", :count => 1)

    creators = column_contents 'Created by'
    creators.should_not include 'Alice'
    creators.should include 'Bill'

    titles = column_contents 'Title'
    titles.should_not include 'First Study'
    titles.should_not include 'Second Study'
    titles.should include 'Advanced Ham'
  end

  def path_should_be(path)
    URI.parse(current_url).path.should == path
  end

  def page_heading_should_be(text)
    page.should have_css "#content > h1, article > h1", :text => text
  end

  def column_contents(name)
    data = page.find('table').all('tr').map do |row|
      row.all('th,td').map &:text
    end
    if n = data[0].index(name)
      (data.transpose)[n][1..-1].join('|')
    else
      ''
    end
  end
end
