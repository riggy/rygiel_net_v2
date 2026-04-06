class Admin::ReferralLinksController < Admin::BaseController
  before_action :set_referral_link, only: %i[edit update destroy]

  def index
    @referral_links = ReferralLink.order(created_at: :desc)
  end

  def new
    @referral_link = ReferralLink.new(active: true)
  end

  def edit; end

  def create
    @referral_link = ReferralLink.new(referral_link_params)
    if @referral_link.save
      redirect_to admin_referral_links_path, notice: "Referral link created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @referral_link.update(referral_link_params)
      redirect_to admin_referral_links_path, notice: "Referral link updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @referral_link.destroy
    redirect_to admin_referral_links_path, notice: "Referral link deleted."
  end

  private

  def set_referral_link
    @referral_link = ReferralLink.find(params[:id])
  end

  def referral_link_params
    params.require(:referral_link).permit(:slug, :name, :target_path, :active)
  end
end
