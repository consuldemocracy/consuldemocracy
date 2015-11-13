class DebatesController < ApplicationController
  include CommentableActions
  include FlagActions

  before_action :parse_search_terms, only: :index
  before_action :parse_tag_filter, only: :index
  before_action :authenticate_user!, except: [:index, :show]

  has_orders %w{hot_score confidence_score created_at most_commented random}, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource
  respond_to :html, :js

  def index_customization
    @featured_debates = Debate.all.sort_by_confidence_score.limit(3) if (@search_terms.blank? && @tag_filter.blank?)
    if @featured_debates.present?
      set_featured_debate_votes(@featured_debates)
      @resources = @resources.where('debates.id NOT IN (?)', @featured_debates.map(&:id))
    end
  end

  def vote
    @debate.register_vote(current_user, params[:value])
    set_debate_votes(@debate)
  end

  def vote_featured
    @debate.register_vote(current_user, 'yes')
    set_featured_debate_votes(@debate)
  end

  private

    def debate_params
      params.require(:debate).permit(:title, :description, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def resource_model
      Debate
    end

    def set_featured_debate_votes(debates)
      @featured_debates_votes = current_user ? current_user.debate_votes(debates) : {}
    end
end
