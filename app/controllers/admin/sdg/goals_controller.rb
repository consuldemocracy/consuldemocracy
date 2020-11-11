class Admin::SDG::GoalsController < Admin::BaseController
  Goal = ::SDG::Goal

  def index
    @goals = Goal.all
  end
end
