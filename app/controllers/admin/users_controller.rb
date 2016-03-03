class Admin::UsersController < Admin::BaseController
  has_filters %w{without_confirmed_hide all with_confirmed_hide}, only: :index

  before_action :load_user, only: [:confirm_hide, :restore]
  before_action :parse_search_terms, only: [:index]

  def index
    @users = User.only_hidden.send(@current_filter).page(params[:page])
    @users = @search_terms.present? ? @users.search(@search_terms) : @users.all
  end

  def show
    @user = User.with_hidden.find(params[:id])
    @debates = @user.debates.with_hidden.page(params[:page])
    @comments = @user.comments.with_hidden.page(params[:page])
  end

  def confirm_hide
    @user.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @user.restore
    Activity.log(current_user, :restore, @user)
    redirect_to request.query_parameters.merge(action: :index)
  end
  
  def parse_search_terms 
    @search_terms = params[:search] if params[:search].present? 
  end 
  
  private

    def load_user
      @user = User.with_hidden.find(params[:id])
    end

end
