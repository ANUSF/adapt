class Adapt::UserMailer < ActionMailer::Base
  include SessionInfo

  ASSDA_EMAIL = "assda@anu.edu.au"
  WEBMASTER = "olaf.delgado-friedrichs@anu.edu.au"

  def create!(*args)
    super
    if Rails.env != 'production'
      original_to = if @recipients.is_a? Array
                      @recipients.join(", ")
                    else
                      @recipients
                    end
      @subject += " [to: #{original_to}]"
      @recipients = current_user.email
      @mail = create_mail
    end
  end

  def submission_notification(study)
    recipients ASSDA_EMAIL
    from ASSDA_EMAIL
    subject "ADAPT: A new study was submitted"
    sent_on Time.now
    body(:study => study, :url => adapt_study_url(study, :host => request_host))
  end

  def approval_notification(study)
    recipients(study.owner.email)
    from ASSDA_EMAIL
    subject "Your submission via ADAPT was approved"
    sent_on Time.now
    body(:study => study, :url => adapt_study_url(study, :host => request_host))
  end

  def archivist_assignment(study)
    recipients(study.archivist.email || ASSDA_EMAIL)
    from ASSDA_EMAIL
    subject "ADAPT: A new study was assigned to you"
    sent_on Time.now
    body(:study => study, :url => adapt_study_url(study, :host => request_host))
  end

  def error_notification(exception)
    recipients WEBMASTER
    from ASSDA_EMAIL
    subject "ADAPT: Error notification"
    sent_on Time.now
    body(:exception => exception)
  end
end
