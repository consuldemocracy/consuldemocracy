class Admin::SDG::GoalsController < Admin::BaseController
  include Translatable
  Goal = ::SDG::Goal

  def index
    @goals = Goal.all
  end

  def edit
    @goal = Goal.find(params[:id])
  end

  def update
    @goal = Goal.find(params[:id])

    if @goal.update(goal_params)
      redirect_to admin_sdg_goals_path, notice: t("admin.sdg.goals.update.notice")
    else
      render "edit"
    end
  end

  private

    def goal_params
      params.require(:sdg_goal).permit(translation_params(Goal))
    end
end
