class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders
  include SendCsvData

  feature_flag :debates

  has_orders %w[created_at]

  def index
    super

    respond_to do |format|
      format.html
      format.csv { send_csv_data @resources }
    end
  end

  def show
    @debate = Debate.find(params[:id])
  end

  private

    def resource_model
      Debate
    end
end
