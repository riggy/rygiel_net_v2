class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: %i[edit update destroy]

  def index
    @projects = Project.positioned
  end

  def sort
    params[:project_ids].each_with_index do |id, index|
      Project.where(id: id).update_all(position: index)
    end
    head :no_content
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to admin_projects_path, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, notice: "Project deleted."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :tech_tags, :url, :featured)
  end
end
