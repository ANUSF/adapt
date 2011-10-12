class Adapt::UserMailer < ActionMailer::Base
  include Adapt::SessionInfo

  ADA_EMAIL = ADAPT::CONFIG['ada.email.admin']
  WEBMASTER = ADAPT::CONFIG['ada.email.webmaster']

  NO_REPLY =
    "THIS IS AN AUTOMATIC NOTIFICATION. PLEASE DO NOT REPLY TO THIS MESSAGE!"

  default :from => ADA_EMAIL

  def my_mail(options = {})
    if Rails.env.starts_with? 'dev'
      mail(:to      => WEBMASTER,
           :subject => "ADAPT to #{options[:to]}: #{options[:subject]}")
    else
      mail(options)
    end
  end

  def submission_notification(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    my_mail(:to      => ADA_EMAIL,
            :subject => "ADAPT: A new study has been submitted")
  end

  def approval_notification(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    my_mail(:to      => reveiver,
            :subject => "Your submission via ADAPT has been approved")
  end

  def archivist_assignment(study)
    @study = study
    @url   = adapt_study_url(study, :host => request_host)

    my_mail(:to      => study.archivist.email || ADA_EMAIL,
            :subject => "ADAPT: A new study has been assigned to you")
  end

  def handover_notification(study, former_archivist)
    @study = study
    @former_archivist = former_archivist
    @url   = adapt_study_url(study, :host => request_host)

    my_mail(:to      => study.archivist.email || ADA_EMAIL,
            :subject => "ADAPT: A study has been handed over to you")
  end

  def error_notification(exception)
    @exception = exception

    my_mail(:to      => WEBMASTER,
            :subject => "ADAPT: Error notification")
  end
end
