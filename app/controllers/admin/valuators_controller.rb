class Admin::ValuatorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @valuators = @valuators.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user
        @valuator = Valuator.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
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