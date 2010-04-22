class UserMailer < ActionMailer::Base
  def welcome_email(user)
    recipients "olaf.delgado@gmail.com"
    from "notifications@example.com"
    subject "Welcome to My Awesome Site"
    sent_on Time.now
    body(:user => user, :url => "http://localhost:3000/login")
  end
end
