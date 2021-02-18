module Budgets
  class InvestmentsController < ApplicationController
    include FeatureFlags
    include CommentableActions
    include FlagActions
    include RandomSeed
    include ImageAttributes
    include Translatable

    PER_PAGE = 10

    before_action :authenticate_user!, except: [:index, :show, :json_data]
    before_action :load_budget, except: :json_data

    authorize_resource :budget, except: :json_data
    load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment",
                                except: :json_data

    before_action :load_ballot, only: [:index, :show]
    before_action :load_heading, only: [:index, :show]
    before_action :set_random_seed, only: :index
    before_action :load_categories, only: [:index, :new, :create, :edit, :update]
    before_action :set_default_budget_filter, only: :index
    before_action :set_view, only: :index
    before_action :load_content_blocks, only: :index

    skip_authorization_check only: :json_data

    feature_flag :budgets

    has_orders %w[most_voted newest oldest], only: :show
    has_orders ->(c) { c.instance_variable_get(:@budget).investments_orders }, only: :index

    valid_filters = %w[not_unfeasible feasible unfeasible unselected selected winners]
    has_filters valid_filters, only: [:index, :show, :suggest]

    invisible_captcha only: [:create, :update], honeypot: :subtitle, scope: :budget_investment

    helper_method :resource_model, :resource_name
    respond_to :html, :js

    def index
      @investments = investments.page(params[:page]).per(PER_PAGE).for_render

      @investment_ids = @investments.pluck(:id)
      @investments_map_coordinates = MapLocation.where(investment: investments).map(&:json_data)

      load_investment_votes(@investments)
      @tag_cloud = tag_cloud
      @remote_translations = detect_remote_translations(@investments)
    end

    def new
    end

    def show
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      @related_contents = Kaminari.paginate_array(@investment.relationed_contents).page(params[:page]).per(5)
      set_comment_flags(@comment_tree.comments)
      load_investment_votes(@investment)
      @investment_ids = [@investment.id]
      @remote_translations = detect_remote_translations([@investment], @comment_tree.comments)
    end

    def create
      @investment.author = current_user

      if @investment.save
        Mailer.budget_investment_created(@investment).deliver_later
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.create.budget_investment")
      else
        render :new
      end
    end

    def update
      if @investment.update(investment_params)
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.update.budget_investment")
      else
        render "edit"
      end
    end

    def destroy
      @investment.destroy!
      redirect_to user_path(current_user, filter: "budget_investments"), notice: t("flash.actions.destroy.budget_investment")
    end

    def vote
      @investment.register_selection(current_user)
      load_investment_votes(@investment)
      respond_to do |format|
        format.html { redirect_to budget_investments_path(heading_id: @investment.heading.id) }
        format.js
      end
    end

    def suggest
      @resource_path_method = :namespaced_budget_investment_path
      @resource_relation    = resource_model.where(budget: @budget).apply_filters_and_search(@budget, params, @current_filter)
      super
    end

    def json_data
      investment = Budget::Investment.find(params[:id])
      data = {
        investment_id: investment.id,
        investment_title: investment.title,
        budget_id: investment.budget.id
      }.to_json

      respond_to do |format|
        format.json { render json: data }
      end
    end

    private

      def resource_model
        Budget::Investment
      end

      def resource_name
        "budget_investment"
      end

      def load_investment_votes(investments)
        @investment_votes = current_user ? current_user.budget_investment_votes(investments) : {}
      end

      def investment_params
        attributes = [:heading_id, :tag_list, :organization_name, :location,
                      :terms_of_service, :skip_map, :related_sdg_list,
                      image_attributes: image_attributes,
                      documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy],
                      map_location_attributes: [:latitude, :longitude, :zoom]]
        params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize
      end

      def load_heading
        if params[:heading_id].present?
          @heading = @budget.headings.find_by_slug_or_id! params[:heading_id]
          @assigned_heading = @ballot&.heading_for_group(@heading.group)
          load_map
        end
      end

      def load_categories
        @categories = Tag.category.order(:name)
      end

      def load_content_blocks
        @heading_content_blocks = @heading.content_blocks.where(locale: I18n.locale) if @heading
      end

      def tag_cloud
        TagCloud.new(Budget::Investment, params[:search])
      end

      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end

      def set_view
        @view = (params[:view] == "minimal") ? "minimal" : "default"
      end

      def investments
        if @current_order == "random"
          @budget.investments.apply_filters_and_search(@budget, params, @current_filter)
                             .sort_by_random(session[:random_seed])
        else
          @budget.investments.apply_filters_and_search(@budget, params, @current_filter)
                             .send("sort_by_#{@current_order}")
        end
      end

      def load_map
        @map_location = MapLocation.load_from_heading(@heading)
      end
  end
end
