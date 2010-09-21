# Load mail configuration if not in test environment
email_settings = YAML::load(File.open("#{Rails.root}/config/email.yml"))
if email_settings[Rails.env]
  ActionMailer::Base.smtp_settings = email_settings[Rails.env]
else
  ActionMailer::Base.delivery_method = :test
end
