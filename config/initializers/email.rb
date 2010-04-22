# Load mail configuration if not in test environment
if RAILS_ENV != 'test'
  email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
  unless email_settings[RAILS_ENV].nil?
    ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV]
  end
end
