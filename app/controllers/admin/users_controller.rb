class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  before_action :load_users, only: [:index]

  def index
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data @users.to_csv}
    end
  end

  private

  def load_users
    
    s = params.dig(:search) || params.dig(:params_csv, :search)
    newslleter = params.dig(:newsletter) || params.dig(:params_csv, :newsletter)
    
    @users = User.all
    @users = @users.where("username ILIKE ? OR email ILIKE ? OR document_number ILIKE ?", "%#{s}%", "%#{s}%", "%#{s}%") if s
    @users = @users.where("newsletter = ?", newslleter) unless newslleter.blank?
    @users = @users.page(params[:page])        
    @users = @users.order(created_at: 'asc')
    
    @params = params if params[:search]

  end
end
