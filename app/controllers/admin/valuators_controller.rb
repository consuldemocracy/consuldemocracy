class Admin::ValuatorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @valuators = @valuators.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:valuator)
                 .page(params[:page])
                 .for_render
  end

  def create
    @valuator = Valuator.new(create_params)
    @valuator.save

    redirect_to admin_valuators_path
  end

  def summary
    @valuators = Valuator.order(spending_proposals_count: :desc)
  end

  private

    def create_params
      params[:valuator][:description] = nil if params[:valuator][:description].blank?
      params.require(:valuator).permit(:user_id, :description)
    end

end
