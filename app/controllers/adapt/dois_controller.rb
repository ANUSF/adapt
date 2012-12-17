class Adapt::DoisController < ApplicationController
  permit(:index, :new, :create, :show, :edit, :update, :destroy,
         :if => :user_is_archivist)

  private

  def user_is_archivist
    current_user.is_archivist
  end

  public

  def index
  end

  def new
    @doi = Adapt::Doi.new :year => Time.now.year
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
