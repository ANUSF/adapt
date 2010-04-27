class UserMailer < ActionMailer::Base
  ASSDA_EMAIL = if Rails.env == 'production'
                  "assda@anu.edu.au"
                else
                  "olaf.delgado@gmail.com"
                end

  def submission_notification(study)
    recipients ASSDA_EMAIL
    from "assda@anu.edu.au"
    subject "A study was submitted via ADAPT"
    sent_on Time.now
    body(:study => study,
         :url => edit_study_url(study, :host => "localhost:3000"))
  end
end
