class SDGManagement::GoalsController < SDGManagement::BaseController
  def index
    @goals = SDG::Goal.order(:code)
  end
end
