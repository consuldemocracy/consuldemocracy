class SDG::GoalsController < ApplicationController
  include FeatureFlags
  feature_flag :sdg
  load_and_authorize_resource find_by: :code, id_param: :code

  def index
    @goals = @goals.order(:code)
  end

  def show
  end
end
