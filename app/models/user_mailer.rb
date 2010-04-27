class UserMailer < ActionMailer::Base
  def submission_notification(study)
    recipients "olaf.delgado@gmail.com"
    from "assda@anu.edu.au"
    subject "A study was submitted via ADAPT"
    sent_on Time.now
    body(:study => study,
         :url => edit_study_url(study, :host => "localhost:3000"))
  end
end
