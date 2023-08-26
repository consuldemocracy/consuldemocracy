class Admin::HiddenUsersController < Admin::BaseController
  include Admin::HiddenContent

  before_action :load_user, only: [:confirm_hide, :restore]

  def index
    @users = hidden_content(User.all)
  end

  def show
    @user = User.with_hidden.find(params[:id])
    @debates = @user.debates.with_hidden.page(params[:page])
    @comments = @user.comments.with_hidden.page(params[:page])
  end

  def confirm_hide
    @user.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @user.full_restore
    Activity.log(current_user, :restore, @user)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_user
      @user = User.with_hidden.find(params[:id])
    end
end
