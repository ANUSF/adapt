class StudiesController < StudiesControllerBase
  permit :index, :new, :create, :if => :logged_in
  permit :show, :if => :may_view
  permit :destroy, :if => :may_edit
  permit :submit, :if => :may_submit

  def index
    @studies =
      case current_user && current_user.role
      when 'contributor' then current_user.studies
      when 'archivist'   then current_user.studies_in_curation
      when 'admin'       then Study.all
      end
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
  
  def show
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

  def submit
    @study.status = "submitted"
    @study.save!
    redirect_to @study
  end
end
