class AUE::GoalsController < ApplicationController
  include FeatureFlags
  feature_flag :aue
  load_and_authorize_resource find_by: :code, id_param: :code

  def index
    @goals = @goals.order(:code)
    @header = WebSection.find_by!(name: "aue").header
  end

  def show
  end

  def help
    @goals = @goals.order(:code)
  end
end
