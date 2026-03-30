class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders

  feature_flag :debates

  has_orders %w[created_at]

  def index
    @debates = Debate.for_render
    @debates = @debates.search(@search_terms) if @search_terms.present?
    @debates = @debates.send("sort_by_#{@current_order}")

    respond_to do |format|
      format.html { @debates = @debates.page(params[:page]) }
      format.csv do
        send_data Debate::Exporter.new(@debates).to_csv,
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
