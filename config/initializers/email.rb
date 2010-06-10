# Load mail configuration if not in test environment
email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
if email_settings[Rails.env]
  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV]
else
  ActionMailer::Base.delivery_method = :test
end
