class Adapt::UserMailer < ActionMailer::Base
  include Adapt::SessionInfo

  ASSDA_EMAIL = "assda@anu.edu.au"
  WEBMASTER = "olaf.delgado-friedrichs@anu.edu.au"

  NO_REPLY =
    "THIS IS AN AUTOMATIC NOTIFICATION. PLEASE DO NOT REPLY TO THIS MESSAGE!"

  default :from => ASSDA_EMAIL

  def submission_notification(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => ASSDA_EMAIL,
         :subject => "ADAPT: A new study was submitted")
  end

  def approval_notification(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => study.owner.email,
         :subject => "Your submission via ADAPT was approved")
  end

  def archivist_assignment(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => study.archivist.email || ASSDA_EMAIL,
         :subject => "ADAPT: A new study was assigned to you")
  end

  def error_notification(exception)
    @exception = exception

    mail(:to      => WEBMASTER,
         :subject => "ADAPT: Error notification")
  end
end
