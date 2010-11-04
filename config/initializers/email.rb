config_file = "#{Rails.root}/config/email.yml"
email_settings = YAML::load(File.open(config_file))[Rails.env] || {}

ActionMailer::Base.delivery_method = method = email_settings[:method] || :test
ActionMailer::Base.smtp_settings = email_settings[:smtp] || {}
