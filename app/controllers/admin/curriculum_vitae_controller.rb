class Admin::CurriculumVitaeController < Admin::BaseController
  before_action :set_curriculum_vitae

  def edit; end

  def update
    @curriculum_vitae.assign_attributes(curriculum_vitae_params)
    if @curriculum_vitae.save
      redirect_to edit_admin_curriculum_vitae_path, notice: "CV updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_curriculum_vitae
    @curriculum_vitae = CurriculumVitae.current
  end

  def curriculum_vitae_params
    params.require(:curriculum_vitae).permit(:content)
  end
end
