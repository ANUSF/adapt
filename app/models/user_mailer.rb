class UserMailer < ActionMailer::Base
  include SessionInfo

  ASSDA_EMAIL = "assda@anu.edu.au"

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
    Rails.logger.warn("User = #{current_user && current_user.name}")
    recipients "grimley.fiendish@gmail.com"
    #recipients ASSDA_EMAIL
    from ASSDA_EMAIL
    subject "ADAPT: A new study was submitted"
    sent_on Time.now
    body(:study => study, :url => edit_study_path(study, :host => host))
  end

  def archivist_assignment(study)
    recipients(study.archivist.email || ASSDA_EMAIL)
    from ASSDA_EMAIL
    subject "ADAPT: A new study was assigned to you"
    sent_on Time.now
    body(:study => study, :url => edit_study_path(study, :host => host))
  end
end
