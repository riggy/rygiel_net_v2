class Admin::NowEntriesController < Admin::BaseController
  before_action :set_now_entry, only: %i[edit update destroy]

  def index
    @now_entries = NowEntry.order(created_at: :desc)
  end

  def new
    @now_entry = NowEntry.new
  end

  def edit; end

  def create
    @now_entry = NowEntry.new(now_entry_params)
    if @now_entry.save
      redirect_to admin_now_entries_path, notice: "Now entry created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @now_entry.update(now_entry_params)
      redirect_to admin_now_entries_path, notice: "Now entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @now_entry.destroy
    redirect_to admin_now_entries_path, notice: "Now entry deleted."
  end

  private

  def set_now_entry
    @now_entry = NowEntry.find(params[:id])
  end

  def now_entry_params
    params.require(:now_entry).permit(:content)
  end
end