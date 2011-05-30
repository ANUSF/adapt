class Adapt::UserMailer < ActionMailer::Base
  include Adapt::SessionInfo

  ADA_EMAIL = "assda@anu.edu.au"
  WEBMASTER = "olaf.delgado-friedrichs@anu.edu.au"

  NO_REPLY =
    "THIS IS AN AUTOMATIC NOTIFICATION. PLEASE DO NOT REPLY TO THIS MESSAGE!"

  default :from => ADA_EMAIL

  def submission_notification(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => ADA_EMAIL,
         :subject => "ADAPT: A new study has been submitted")
  end

  def approval_notification(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => study.owner.email,
         :subject => "Your submission via ADAPT has been approved")
  end

  def archivist_assignment(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => study.archivist.email || ADA_EMAIL,
         :subject => "ADAPT: A new study has been assigned to you")
  end

  def handover_notification(study, former_archivist)
    @study = study
    @former_archivist = former_archivist
    @url   = adapt_study_url(study, :host => request_host)

    mail(:to      => study.archivist.email || ADA_EMAIL,
         :subject => "ADAPT: A study has been handed over to you")
  end

  def error_notification(exception)
    @exception = exception

    mail(:to      => WEBMASTER,
         :subject => "ADAPT: Error notification")
  end
end
