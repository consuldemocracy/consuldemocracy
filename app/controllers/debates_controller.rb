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

  load_and_authorize_resource except: [:new, :create, :edit]
  skip_authorization_check
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  # Funciones y filtros para los usuarios
  before_action :is_admin?, except: [:show, :edit]

  before_action :actual_users, only: [:show, :edit]
  has_filters %w[id nombre], except: [:show, :index]

  def is_admin?
    if !current_user.administrator?
      redirect_to root_path
      flash[:alert] = t "not_authorized.view"
    end
  end

  # Funciones para cargar los usuarios
  def actual_users
    @debate = Debate.find_by_id(params[:id])
    @project_users = []
    @users_actuales = DebateParticipant.where(debate_id: @debate.id).order(user_id: :asc)
    @users_actuales.each do |item|
      @project_users += User.where(id: item.user_id)
    end
    @project_users
  end

  def load_components(filter)
    arr_users = []
    @except_users = actual_users()
    @except_users.each do |item|
      arr_users << item.id
    end
    if filter == 'nombre'
      @users = User.where.not(id: arr_users).order(username: :asc)
    else filter == 'id'
      @users = User.where.not(id: arr_users).order(id: :desc)
    end
  end

  def load_all(filter)
    @project_users = []
    if filter == 'nombre'
      @users = User.all.order(username: :asc)
    else filter == 'id'
      @users = User.all.order(id: :desc)
    end
  end
  # Fin

  def index_customization
    @featured_debates = @debates.featured
  end

  def new
    @debate = Debate.new
    load_all(@current_filter)
  end

  def create
    @debate = Debate.new(debate_params.merge(author: current_user))
    if @debate.save

      user_elements = params[:user_ids]
      @debate.save_component(user_elements)

      redirect_to @debate, notice: 'Debate creado correctamente.'
    else
      load_all(@current_filter)
      render :new
    end
  end

  def edit
    load_components(@current_filter)
  end

  def update
    if @debate.update(debate_params)

      user_elements = params[:user_ids]
      @debate.save_component(user_elements)

      delete_user_elements = params[:delete_user_ids]
      @debate.delete_component(delete_user_elements)

      redirect_to @debate, notice: 'Debate actualizado correctamente.'
    else
      load_components(@current_filter)
      render :edit
    end
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
      attributes = [:imagen, :tag_list, :terms_of_service, :related_sdg_list, user_ids: [], delete_user_ids: []]
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
