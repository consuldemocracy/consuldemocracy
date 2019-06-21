module ChangeLogHelper

  def show_investment_log
    @log = Budget::Investment::ChangeLog.find_by(id: params[:id])
    render "admin/change_logs/show"
  end

end
