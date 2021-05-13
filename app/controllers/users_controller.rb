class UsersController < ApplicationController
  has_filters %w[proposals participants participants_d participants_p projects projects_geozone debates budget_investments comments follows], only: :show

  #load_and_authorize_resource
  load_and_authorize_resource except: [:change,:update]
#   skip_load_and_authorize_resource :only => :edit
  skip_authorization_check # JHH: Tener esto controlado
  helper_method :author?
  helper_method :valid_interests_access?

  def show
    load_filtered_activity if valid_access?
  end

  def change
    @user = User.find_by_id(params[:id])
    @geozones = Geozone.all.order(Arel.sql("LOWER(name)"))
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User successfully updated'
    else
        render 'edit', notice: 'Failed to update profile.'
    end
  end

  private

    def user_params
      params.require(:user).permit(:username, :geozone_id)
    end

    def set_activity_counts
      @activity_counts = ActiveSupport::HashWithIndifferentAccess.new(
                          proposals: Proposal.where(author_id: @user.id).count,
                          participants: ProposalParticipant.where(user_id: @user.id).count,
                          participants_d: DebateParticipant.where(user_id: @user.id).count,
                          participants_p: PageParticipant.where(user_id: @user.id).count,
                          projects: UserOnProject.where(user_id: @user.id).count,
                          projects_geozone: Project.where(["geozone_id = ? and public = ?", @user.geozone_id, "t"]).count,
                          debates: (Setting["process.debates"] ? Debate.where(author_id: @user.id).count : 0),
                          budget_investments: (Setting["process.budgets"] ? Budget::Investment.where(author_id: @user.id).count : 0),
                          comments: only_active_commentables.count,
                          follows: @user.follows.map(&:followable).compact.count)
    end

    def load_filtered_activity
      set_activity_counts
      case params[:filter]
      when "proposals" then load_proposals
      when "participants" then load_participants
      when "participants_d" then load_participants_d
      when "participants_p" then load_participants_p
      when "projects" then load_projects
      when "projects_geozone" then load_projects_geozone
      when "debates" then load_debates
      when "budget_investments" then load_budget_investments
      when "comments" then load_comments
      when "follows" then load_follows
      else load_available_activity
      end
    end

    def load_available_activity
      if @activity_counts[:proposals] > 0
        load_proposals
        @current_filter = "proposals"
      elsif @activity_counts[:projects] > 0
        load_projects
        @current_filter = "projects"
      elsif @activity_counts[:projects_geozone] > 0
        load_projects_geozone
        @current_filter = "projects_geozone"
      elsif @activity_counts[:participants] > 0
        load_participants
        @current_filter = "participants"
      elsif @activity_counts[:participants_d] > 0
        load_participants_d
        @current_filter = "participants_d"
      elsif @activity_counts[:participants_p] > 0
        load_participants_p
        @current_filter = "participants_p"
      elsif @activity_counts[:debates] > 0
        load_debates
        @current_filter = "debates"
      elsif  @activity_counts[:budget_investments] > 0
        load_budget_investments
        @current_filter = "budget_investments"
      elsif  @activity_counts[:comments] > 0
        load_comments
        @current_filter = "comments"
      elsif  @activity_counts[:follows] > 0
        load_follows
        @current_filter = "follows"
      end
    end

    def load_projects
      @participants_project = []
      @project_participants = UserOnProject.where(user_id: @user.id)
      @project_participants.each do |index|
        @participants_project += Project.where(id: index.project_id)
      end
      @participants_project
    end

    def load_projects_geozone
      @projects = Project.where(["geozone_id = ? and public = ?", @user.geozone_id, "t"])
    end

    def load_proposals
      @proposals = Proposal.created_by(@user).order(created_at: :desc).page(params[:page])
    end

    # JHH: Cargamos ademas las propuestas en las que el usuario es participante
    #@proposal_part = ProposalParticipant.where(user_id: @user.id)
    def load_participants
      @participants = []
      @proposal_participate = ProposalParticipant.where(user_id: @user.id).order(created_at: :desc).page(params[:page])
      @proposal_participate.each do |part|
        @participants += Proposal.where(id: part.proposal_id).order(created_at: :desc).page(params[:page])
      end
      @participants
    end

    def load_participants_d
      @participants_d = []
      @debate_participate = DebateParticipant.where(user_id: @user.id).order(created_at: :desc).page(params[:page])
      @debate_participate.each do |part|
        @participants_d += Debate.where(id: part.debate_id).order(created_at: :desc).page(params[:page])
      end
      @participants_d
    end

    def load_participants_p
      @participants_p = []
      @page_participate = PageParticipant.where(user_id: @user.id).order(created_at: :desc).page(params[:page])
      @page_participate.each do |part|
        @participants_p += SiteCustomization::Page.where(id: part.site_customization_pages_id).order(created_at: :desc).page(params[:page])
      end
      @participants_p
    end
    #Fin

    def load_debates
      @debates = Debate.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_comments
      @comments = only_active_commentables.includes(:commentable).order(created_at: :desc).page(params[:page])
    end

    def load_budget_investments
      @budget_investments = Budget::Investment.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_follows
      @follows = @user.follows.group_by(&:followable_type)
    end

    def valid_access?
#       @user = User.find_by_id(params[:id])
      if user_signed_in?
        authorized_current_user? || current_user.administrator? || @user.public_activity
      else
        return false
      end
    end

    def valid_interests_access?
      @user.public_interests || authorized_current_user?
    end

    def author?(proposal)
      proposal.author_id == current_user.id if current_user
    end

    def authorized_current_user?
      @authorized_current_user ||= current_user && (current_user == @user || current_user.moderator? || current_user.administrator?)
    end

    def all_user_comments
      Comment.not_valuations.not_as_admin_or_moderator.where(user_id: @user.id)
    end

    def only_active_commentables
      disabled_commentables = []
      disabled_commentables << "Debate" unless Setting["process.debates"]
      disabled_commentables << "Budget::Investment" unless Setting["process.budgets"]
      if disabled_commentables.present?
        all_user_comments.where.not(commentable_type: disabled_commentables)
      else
        all_user_comments
      end
    end

end
