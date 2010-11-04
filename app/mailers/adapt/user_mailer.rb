class Adapt::UserMailer < ActionMailer::Base
  include Adapt::SessionInfo

  ASSDA_EMAIL = "assda@anu.edu.au"
  WEBMASTER = "olaf.delgado-friedrichs@anu.edu.au"

  default :from => ASSDA_EMAIL
  default_url_options[:host] = request_host

  def create!(*args)
    super
    unless Rails.env.production?
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
    @study = study
    @url   = adapt_study_url(study)

    mail(:to      => ASSDA_EMAIL,
         :subject => "ADAPT: A new study was submitted")
  end

  def approval_notification(study)
    @study = study
    @url   = adapt_study_url(study)

    mail(:to      => study.owner.email,
         :subject => "Your submission via ADAPT was approved")
  end

  def archivist_assignment(study)
    @study = study
    @url   = adapt_study_url(study)

    mail(:to      => study.archivist.email || ASSDA_EMAIL,
         :subject => "ADAPT: A new study was assigned to you")
  end

  def error_notification(exception)
    @exception = exception

    mail(:to      => WEBMASTER,
         :subject => "ADAPT: Error notification")
  end
end
