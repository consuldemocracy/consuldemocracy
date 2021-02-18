class Admin::ValuatorsController < Admin::BaseController
  load_and_authorize_resource

  def show
    @valuator = Valuator.find(params[:id])
  end

  def index
    @valuators = @valuators.page(params[:page])
  end

  def search
    @users = User.search(params[:search])
                 .includes(:valuator)
                 .page(params[:page])
  end

  def create
    @valuator = Valuator.new(valuator_params)
    @valuator.save!

    redirect_to admin_valuators_path
  end

  def edit
    @valuator = Valuator.find(params[:id])
    @valuator_groups = ValuatorGroup.all
  end

  def update
    @valuator = Valuator.find(params[:id])
    if @valuator.update(valuator_params)
      notice = t("admin.valuators.form.updated")
      redirect_to [:admin, @valuator], notice: notice
    else
      render :edit
    end
  end

  def destroy
    @valuator.destroy!
    redirect_to admin_valuators_path
  end

  private

    def valuator_params
      params[:valuator][:description] = nil if params[:valuator][:description].blank?
      params.require(:valuator).permit(:user_id, :description, :valuator_group_id,
                                       :can_comment, :can_edit_dossier)
    end
end
