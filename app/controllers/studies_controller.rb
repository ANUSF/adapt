class StudiesController < ApplicationController
  permit :index, :new, :create, :if => :logged_in
  permit :show, :edit, :update, :destroy, :if => :current_user_owns_study

  before_filter :find_study, :only => [ :show, :edit, :update, :destroy ]

  # # -- permit can be called with a block, too
  # permit :show do |user, params|
  #   user.studies.find_by_id(params[:id])
  # end

  def index
    @studies = current_user.studies.all
  end
  
  def show
  end
  
  def new
    @study = current_user.studies.new
  end
  
  def create
    @study = current_user.studies.new(params[:study])
    @study.status = "incomplete"
    if @study.save
      flash[:notice] = "Study entry created. Further input required."
      redirect_to edit_study_datum_url(@study)
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    current = @study.attributes
    @study.attributes = params[:study]
    update_needed = @study.attributes != current

    if not update_needed or @study.save
      flash[:notice] = "Edits for page 1 were saved." if update_needed
      redirect_to edit_study_datum_url(@study)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @study.destroy
    flash[:notice] = "Successfully destroyed study."
    redirect_to studies_url
  end

  private

  def find_study
    return @study if defined? @study
    @study = logged_in && current_user.studies.find_by_id(params[:id])
  end

  def current_user_owns_study
    not find_study.nil?
  end
end
