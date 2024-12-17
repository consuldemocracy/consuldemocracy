module Budgets
  class InvestmentsController < ApplicationController 
    include FeatureFlags
    include CommentableActions
    include FlagActions
    include RandomSeed
    include ImageAttributes
    include DocumentAttributes
    include MapLocationAttributes
    include Translatable

    PER_PAGE = 10

    before_action :authenticate_user!, except: [:index, :show]
    before_action :load_budget

    authorize_resource :budget
    load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment"

    before_action :load_ballot, only: [:index, :show]
    before_action :load_heading, only: [:index, :show]
    before_action :set_random_seed, only: :index
    before_action :load_categories, only: :index
    before_action :set_default_investment_filter, only: :index
    before_action :set_view, only: :index

    feature_flag :budgets

    has_orders %w[most_voted newest oldest], only: :show
    has_orders ->(c) { c.instance_variable_get(:@budget).investments_orders }, only: :index
    has_filters ->(c) { c.instance_variable_get(:@budget).investments_filters },
                only: [:index, :show, :suggest]

    invisible_captcha only: [:create, :update], honeypot: :subtitle, scope: :budget_investment

    helper_method :resource_model, :resource_name
    respond_to :html, :js

    def index
      @investments = investments.page(params[:page]).per(PER_PAGE).for_render
      @investment_ids = @investments.ids

      @investments_in_map = investments
      @tag_cloud = tag_cloud
      @remote_translations = detect_remote_translations(@investments)
    end

    def new
      puts "Starting new method"
    @budget = Budget.find(params[:budget_id])
    puts "Found Budget ID: #{@budget.id}"
    # Check for proposal ID before proceeding
    if params[:proposal_id].present?
    @proposal = Proposal.find(params[:proposal_id])
    puts "Found Proposal ID: #{@proposal.id}"
    
    @investment = Budget::Investment.new(map_proposal_to_investment(@proposal))
    puts "Initialized new Investment with attributes: #{@investment.attributes.inspect}"
    @investment.terms_of_service = true    
    if @investment.save
      puts "Successfully saved new Investment ID: #{@investment.id}"
      copy_image(@proposal, @investment)
      copy_documents(@proposal, @investment)
      copy_sdg_relations(@proposal, @investment)
      redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.create.budget_investment")
    else
      puts "Failed to save new Investment"
      render :new, alert: "Failed to create investment"
    end
    end
    end

    def show
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)
      @investment_ids = [@investment.id]
      @remote_translations = detect_remote_translations([@investment], @comment_tree.comments)
    end

    def create
      @investment.author = current_user
      @investment.heading = @budget.headings.first if @budget.single_heading?

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
        puts "Investment Params: #{investment_params.inspect}" # Debugging statement
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.update.budget_investment")
      else
        puts "Investment Params: #{investment_params.inspect}" # Debugging statement
        render "edit"
        
      end
    end

    def destroy
      @investment.destroy!
      redirect_to user_path(current_user, filter: "budget_investments"),
                  notice: t("flash.actions.destroy.budget_investment")
    end

    def suggest
      @resource_path_method = :namespaced_budget_investment_path
      @resource_relation    = resource_model.where(budget: @budget)
                                            .apply_filters_and_search(@budget, params, @current_filter)
      super
    end

    private

      def map_proposal_to_investment(proposal)
    {
      author_id: proposal.author_id,
      hidden_at: proposal.hidden_at,
      flags_count: proposal.flags_count,
      ignored_flag_at: proposal.ignored_flag_at,
      cached_votes_up: proposal.cached_votes_up,
      comments_count: proposal.comments_count,
      confirmed_hide_at: proposal.confirmed_hide_at,
      confidence_score: proposal.confidence_score,
      created_at: proposal.created_at,
      updated_at: proposal.updated_at,
      responsible_name: proposal.responsible_name,
      video_url: proposal.video_url,
      tsv: proposal.tsv,
      map_location: proposal.map_location,
      community_id: proposal.community_id,
      selected: proposal.selected,
      tag_list: proposal.tag_list,
      ml_tag_list: proposal.ml_tag_list,
      milestone_tag_list: proposal.milestone_tag_list,
      title: proposal.title,
      summary: proposal.summary,
      description: proposal.description,
#      proposal_id: proposal.id, # This is a hidden field
      budget_id: params[:budget_id], # This is a hidden field
      group_id: params[:group_id], # This is a hidden field
      heading_id: params[:heading_id] # This is a hidden field
    }
  end
  
  def copy_image(proposal, investment)
    puts "Starting copy_image method"
    puts "Proposal ID: #{proposal.id}"
    puts "Investment ID: #{investment.id}"

    images = Image.where(imageable_type: "Proposal", imageable_id: proposal.id)
    puts "Found #{images.count} images for Proposal ID: #{proposal.id}"

    return if images.empty?

    images.each do |image|
      puts "Duplicating Image ID: #{image.id}"
      @new_image = image.dup
      @new_image.imageable_type = "Budget::Investment"
      @new_image.imageable_id = investment.id
      @new_image.attachment.attach(image.attachment.blob)
      if @new_image.save
        puts "Successfully created duplicated Image ID: #{@new_image.id} for Investment ID: #{investment.id}"
      else
        puts "Failed to create duplicated Image ID: #{image.id} for Investment ID: #{investment.id}"
        puts "Validation errors: #{@new_image.errors.full_messages.join(", ")}"
      end
    end

    puts "Completed copy_image method"
  end
  
  def copy_documents(proposal, investment)
    puts "Starting copy_documents method"
    puts "Proposal ID: #{proposal.id}"
    puts "Investment ID: #{investment.id}"
    documents = Document.where(documentable_type: "Proposal", documentable_id: proposal.id)
    puts "Found #{documents.count} documents for Proposal ID: #{proposal.id}"
    return if documents.empty?  # Early exit if no documents to copy
    documents.each do |document|
    puts "Duplicating Document ID: #{document.id}"
                @new_document = document.dup
                @new_document.documentable_type = "Budget::Investment"
                @new_document.documentable_id = investment.id    # Handle attachment if documents have attachments
                if document.respond_to?(:attachment) && document.attachment.attached?
                  @new_document.attachment.attach(document.attachment.blob)
                end
                if @new_document.save
                puts "Successfully created duplicated Document ID: #{@new_document.id} for Investment ID: #{investment.id}"
                  else
                   puts "Failed to create duplicated Document ID: #{document.id} for Investment ID: #{investment.id}"
                   puts "Validation errors: #{@new_document.errors.full_messages.join(", ")}"
                  end
                 end
                   puts "Completed copy_documents method"
  end
     
     def copy_sdg_relations(proposal, investment)
  puts "Starting copy_sdgs method"
  puts "Proposal ID: #{proposal.id}"
  puts "Investment ID: #{investment.id}"

  # Find SDG::Relation records associated with the proposal
  sdg_relations = proposal.sdg_relations

  # Create new SDG::Relation records for the investment
  sdg_relations.each do |relation|
    investment.sdg_relations.create(
      related_sdg: relation.related_sdg,
      related_sdg_type: relation.related_sdg_type
    )
  end

  # Save the changes
  if investment.save
    puts "Successfully copied SDGs from Proposal ID: #{proposal.id} to Investment ID: #{investment.id}"
  else
    puts "Failed to copy SDGs: #{investment.errors.full_messages.join(', ')}"
  end
end  

      def resource_model
        Budget::Investment
      end

      def resource_name
        "budget_investment"
      end

      def investment_params
        params.require(:budget_investment).permit(allowed_params)
      end

      def allowed_params
        attributes = [:video_url, :estimated_price, :summary,  :heading_id, :tag_list, :organization_name, :location,
                      :terms_of_service, :related_sdg_list,
                      image_attributes: image_attributes,
                      documents_attributes: document_attributes,
                      map_location_attributes: map_location_attributes]

        [*attributes, translation_params(Budget::Investment)]
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize
      end

      def load_heading
        if params[:heading_id].present?
          @heading = @budget.headings.find_by_slug_or_id! params[:heading_id]
          @assigned_heading = @ballot&.heading_for_group(@heading.group)
        elsif @budget.single_heading?
          @heading = @budget.headings.first
        end
      end

      def load_categories
        @categories = Tag.category.order(:name)
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

      def investments_with_filters
        @budget.investments.apply_filters_and_search(@budget, params, @current_filter)
      end

      def investments
        if @current_order == "random"
          investments_with_filters.sort_by_random(session[:random_seed])
        else
          investments_with_filters.send("sort_by_#{@current_order}")
        end
      end

      def set_default_investment_filter
        if @budget&.finished?
          params[:filter] ||= "winners"
        elsif @budget&.publishing_prices_or_later?
          params[:filter] ||= "selected"
        end
      end
  end
end
