class DebatesController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions

  before_action :parse_tag_filter, only: :index
  before_action :authenticate_user!, except: [:index, :show, :map]

  feature_flag :debates

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Debate.debates_orders(c.current_user) }, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def index_customization
    @featured_debates = @debates.featured
  end

  def show
    super
    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)
  end

  def vote
    @debate.register_vote(current_user, params[:value])
    set_debate_votes(@debate)
  end

  def unmark_featured
    @debate.update_attribute(:featured_at, nil)
    redirect_to request.query_parameters.merge(action: :index)
  end

  def mark_featured
    @debate.update_attribute(:featured_at, Time.current)
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def debate_params
      params.require(:debate).permit(:title, :description, :tag_list, :terms_of_service)
    end

    def resource_model
      Debate
    end

end
