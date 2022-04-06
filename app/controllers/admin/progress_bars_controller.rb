class Admin::ProgressBarsController < Admin::BaseController
  include Translatable

  before_action :load_progressable
  before_action :load_progress_bar, only: [:edit, :update, :destroy]
  helper_method :progress_bars_index

  def index
  end

  def new
    @progress_bar = @progressable.progress_bars.new
  end

  def create
    @progress_bar = @progressable.progress_bars.new(progress_bar_params)
    if @progress_bar.save
      redirect_to progress_bars_index, notice: t("admin.progress_bars.create.notice")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @progress_bar.update(progress_bar_params)
      redirect_to progress_bars_index, notice: t("admin.progress_bars.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @progress_bar.destroy!
    redirect_to progress_bars_index, notice: t("admin.progress_bars.delete.notice")
  end

  private

    def progress_bar_params
      params.require(:progress_bar).permit(allowed_params)
    end

    def allowed_params
      [
        :kind,
        :percentage,
        translation_params(ProgressBar)
      ]
    end

    def load_progressable
      @progressable = progressable
    end

    def progressable
      raise "This method must be implemented in subclass #{self.class.name}"
    end

    def load_progress_bar
      @progress_bar = progressable.progress_bars.find(params[:id])
    end

    def progress_bars_index
      admin_polymorphic_path(@progressable.progress_bars.new)
    end
end
