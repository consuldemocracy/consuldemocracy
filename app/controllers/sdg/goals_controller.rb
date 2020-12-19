class SDG::GoalsController < ApplicationController
  include FeatureFlags
  feature_flag :sdg
  load_and_authorize_resource

  def index
    @goals = @goals.order(:code)
  end
end
