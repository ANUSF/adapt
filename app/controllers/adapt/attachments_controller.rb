class Adapt::AttachmentsController < ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced resources before performing authorization
  before_authorization_filter :find_attachment

  # -- declare access permissions via the 'verboten' plugin
  permit :download, :if => :may_view

  private

  # Finds the attachment with id specified in the request and the study it
  # belongs to.
  def find_attachment
    @attachment = Adapt::Attachment.find_by_id(params[:id])
    @study = @attachment.study if @attachment
  end

  # Whether the current user may view the referenced study.
  def may_view
    @study and @study.can_be_viewed_by current_user
  end

  # ----------------------------------------------------------------------------
  # Actions this controller provides.
  # ----------------------------------------------------------------------------
  public

  # This custom action provides a file download for the referenced attachment.
  def download
    use_xsendfile = false # use in production when it's working on our server

    send_file(@attachment.stored_path,
              :filename => @attachment.name,
              :disposition => "attachment",
              :stream => true,
              :buffer_size => 1024 * 1024,
              :x_sendfile => use_xsendfile)
  end
end
