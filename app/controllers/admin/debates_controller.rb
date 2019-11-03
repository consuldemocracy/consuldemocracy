class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders
  include DownloadSettingsHelper

  feature_flag :debates

  has_orders %w[created_at]

  def index
    super

    respond_to do |format|
      format.html
      format.csv do
        send_data to_csv(@resources),
                  type: "text/csv",
                  disposition: "attachment",
                  filename: "debates.csv"
      end
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
