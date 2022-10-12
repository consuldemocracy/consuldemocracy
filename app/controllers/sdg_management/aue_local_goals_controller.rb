class SDGManagement::AUELocalGoalsController < SDGManagement::BaseController
  include Translatable

  load_and_authorize_resource class: "AUE::LocalGoal"

  def index
    @aue_local_goals = @aue_local_goals.sort
  end

  def new
  end

  def create
    if @aue_local_goal.save
      redirect_to sdg_management_aue_local_goals_path, notice: t("sdg_management.local_goals.create.notice")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @aue_local_goal.update(aue_local_goal_params)
      redirect_to sdg_management_aue_local_goals_path, notice: t("sdg_management.local_goals.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @aue_local_goal.destroy!
    redirect_to sdg_management_aue_local_goals_path, notice: t("sdg_management.local_goals.destroy.notice")
  end

  private

    def aue_local_goal_params
      params.require(:aue_local_goal).permit(allowed_params)
    end

    def allowed_params
      translations_attributes = translation_params(::AUE::LocalGoal)

      [:code, translations_attributes]
    end
end
