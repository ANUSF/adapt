module HelperMethods
  # Put helper methods you need to be available in all tests here.

  def login_as(name)
    visit "/users/sign_in?name=#{name}"
  end

  def create_user(name, options = {})
    User.make :name => name, :role => options[:role] || 'contributor'
  end

  def create_study(title, options = {})
    user = User.find_by_name(options[:owner]) || User.first
    Adapt::Study.make(:owner => user, :title => title)
  end

  def set_study_status_for(title, options = {})
    Adapt::Study.find_by_title(title).update_attribute(:status, options[:to])
  end

  def set_archivist_for(title, options = {})
    study = Adapt::Study.find_by_title(title)
    study.archivist = User.find_by_name(options[:to])
    study.temporary_identifier = "deposit_99999" # Hack to make store go through!
    study.save!
  end

  def manually_upload_attachment_for(title, options = {})
    study = Adapt::Study.find_by_title(title)
    path = File.join(study.manual_upload_path, options[:name])
    File.open(path, "wb") { |fp| fp.write options[:data] }
  end

  def there_should_be_an_attachment_for(title, options = {})
    study = Adapt::Study.find_by_title title
    attachment = study.attachments.find_by_name options[:name]
    attachment.should be_true
    attachment.data.should == options[:data] if options[:data]
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

  def there_should_be_a_button(text)
    page.should have_css("input[value=\"#{text}\"]")
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

  ADA_EMAIL = 'assda@anu.edu.au'

  def check_study_notification(study, recipient, subject, *body_patterns)
    email = ActionMailer::Base.deliveries.first
    email.should_not be_nil
    email.from.should    == [ADA_EMAIL]
    email.to.should      == [recipient]
    email.subject.should == subject
    body_patterns.each { |pattern| email.body.should include(pattern) }
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
