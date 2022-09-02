class SDGManagement::AUEGoalsController < SDGManagement::BaseController
  load_and_authorize_resource class: "AUE::Goal"

  def index
    @aue_goals = @aue_goals.order(:code)
  end
end
