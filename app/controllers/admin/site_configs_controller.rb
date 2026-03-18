class Admin::SiteConfigsController < Admin::BaseController
  def index
    @site_configs = SiteConfig.order(:key)
  end

  def edit
    @site_config = SiteConfig.find(params[:id])
  end

  def update
    @site_config = SiteConfig.find(params[:id])
    if @site_config.update(site_config_params)
      redirect_to admin_site_configs_path, notice: "Config updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def site_config_params
    params.require(:site_config).permit(:value)
  end
end
