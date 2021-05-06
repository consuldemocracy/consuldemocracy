class DebatesController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions
  include Translatable

  before_action :authenticate_user!, except: [:show, :map]
  before_action :set_view, only: :index
  before_action :debates_recommendations, only: :index, if: :current_user

  feature_flag :debates

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Debate.debates_orders(c.current_user) }, only: :index
  has_orders %w[most_voted newest oldest], only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  # JHH:
  before_action :is_admin?, except: [:show, :edit]
  before_action :load_participants, :actual_people, only: [:edit,:new]

  def is_admin?
    if current_user.administrator?
      flash[:notice] = t "authorized.title"
    else
      redirect_to root_path
      flash[:alert] = t "not_authorized.title"
    end
  end

  def actual_people
    @people = []
    @debate_actual_participant = DebateParticipant.where(debate_id: @debate.id).order(user_id: :asc)
    @debate_actual_participant.each do |part|
      @people += User.where(id: part.user_id)
    end
    @people
  end



  def load_participants
    arr = []
    @except = actual_people()
    @except.each do |index|
      arr << index.id
    end
    @participants = User.where.not(id: arr).order(id: :asc)
  end
  #Fin

  def index_customization
    @featured_debates = @debates.featured
  end

  def show
    super
    @related_contents = Kaminari.paginate_array(@debate.relationed_contents).page(params[:page]).per(5)
    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)
  end

  def vote
    @debate.register_vote(current_user, params[:value])
    set_debate_votes(@debate)
  end

  def unmark_featured
    @debate.update!(featured_at: nil)
    redirect_to debates_path
  end

  def mark_featured
    @debate.update!(featured_at: Time.current)
    redirect_to debates_path
  end

  def disable_recommendations
    if current_user.update(recommended_debates: false)
      redirect_to debates_path, notice: t("debates.index.recommendations.actions.success")
    else
      redirect_to debates_path, error: t("debates.index.recommendations.actions.error")
    end
  end

  private

    def debate_params
      attributes = [:delete_debate_users_id, :debate_users_id, :tag_list, :terms_of_service, :related_sdg_list]
      params.require(:debate).permit(attributes, translation_params(Debate))
    end

    def resource_model
      Debate
    end

    def set_view
      @view = (params[:view] == "minimal") ? "minimal" : "default"
    end

    def debates_recommendations
      if Setting["feature.user.recommendations_on_debates"] && current_user.recommended_debates
        @recommended_debates = Debate.recommendations(current_user).sort_by_random.limit(3)
      end
    end
end
