class UserMailer < ActionMailer::Base
  ASSDA_EMAIL = if Rails.env == 'production'
                  "assda@anu.edu.au"
                else
                  "olaf.delgado@gmail.com"
                end

  def submission_notification(study)
    recipients ASSDA_EMAIL
    from "assda@anu.edu.au"
    subject "ADAPT: A new study was submitted"
    sent_on Time.now
    body(:study => study,
         :url => edit_study_url(study, :host => "localhost:3000"))
  end

  def archivist_assignment(study)
    recipients(study.archivist.email || ASSDA_EMAIL)
    from "assda@anu.edu.au"
    subject "ADAPT: A new study was assigned to you"
    sent_on Time.now
    body(:study => study,
         :url => edit_study_url(study, :host => "localhost:3000"))
  end
end
