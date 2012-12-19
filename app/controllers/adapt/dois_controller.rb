class Adapt::DoisController < ApplicationController
  before_authorization_filter :find_doi, :except => [ :index, :new, :create ]

  permit(:index, :new, :create, :show, :edit, :update, :destroy,
         :if => :user_is_archivist)
  permit :send, :if => :user_is_archivist

  private

  def find_doi
    @doi = Adapt::Doi.find_by_id(params[:id])
  end

  def user_is_archivist
    current_user.is_archivist
  end

  public

  def index
  end

  def new
    @doi = Adapt::Doi.new :year => Time.now.year,
                          :publisher => "Australian Data Archive"
  end

  def create
    if params[:result] == "Cancel"
      flash[:notice] = 'DOI creation cancelled.'
      redirect_to root_url
    else
      @doi = Adapt::Doi.new(params[:adapt_doi])

      if @doi.save
        flash[:notice] = 'DOI descriptor created.'
        redirect_to adapt_doi_url(@doi)
      else
        flash.now[:error] =
          "DOI creation failed. Please correct the fields marked in red."
        render :action => :new
      end
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  # === Extra action for this resource

  def transmit
  end
end
