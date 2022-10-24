class UsersController < ApplicationController
  has_filters %w{proposals debates budget_investments comments votes ballot_lines follows}, only: :show

  load_and_authorize_resource
  helper_method :valid_interests_access?

  def show
    raise CanCan::AccessDenied if params[:filter] == "follows" && !valid_interests_access?(@user)
  end

  private

    def set_activity_counts
      @activity_counts = HashWithIndifferentAccess.new(
                          proposals: Proposal.where(author_id: @user.id).count,
                          debates: (Setting['feature.debates'] ? Debate.where(author_id: @user.id).count : 0),
                          budget_investments: (Setting['feature.budgets'] ? Budget::Investment.where(author_id: @user.id).count : 0),
                          comments: only_active_commentables.count,
                          votes: votes_count,
                          ballot_lines: ballot_lines_count,
                          follows: @user.follows.map(&:followable).compact.count)
    end

    def load_filtered_activity
      set_activity_counts
      case params[:filter]
      when "proposals" then load_proposals
      when "debates"   then load_debates
      when "budget_investments" then load_budget_investments
      when "comments" then load_comments
      when "votes"  then load_votes
      when "ballot_lines"  then load_ballot_lines
      when "follows" then load_follows
      when "votes"  then load_votes
      when "ballot_lines"  then load_ballot_lines
      else load_available_activity
      end
    end

    def load_available_activity
      if @activity_counts[:proposals] > 0
        load_proposals
        @current_filter = "proposals"
      elsif @activity_counts[:debates] > 0
        load_debates
        @current_filter = "debates"
      elsif  @activity_counts[:budget_investments] > 0
        load_budget_investments
        @current_filter = "budget_investments"
      elsif  @activity_counts[:comments] > 0
        load_comments
        @current_filter = "comments"
      elsif  @activity_counts[:votes] > 0
        load_votes
        @current_filter = "votes"
      elsif  @activity_counts[:ballot_lines] > 0
        load_ballot_lines
        @current_filter = "ballot_lines"
      elsif  @activity_counts[:follows] > 0
        load_follows
        @current_filter = "follows"
      elsif  @activity_counts[:votes] > 0
        load_votes
        @current_filter = "votes"
      elsif  @activity_counts[:ballot_lines] > 0
        load_ballot_lines
        @current_filter = "ballot_lines"
      end
    end

    def votes_count
      return 0 if @user != current_user
      budgets_current = Budget.includes(:investments).where(phase: 'selecting')
      investment_ids = budgets_current.map { |b| b.investment_ids }.flatten
      @user.votes.for_type(Budget::Investment).where(votable_id: investment_ids).size
    end

    def ballot_lines_count
      return 0 if @user != current_user
      ballot = Budget::Ballot.includes(:lines).where(user_id: @user.id).last
      ballot.present? ? ballot.lines.count : 0
    end

    def load_votes
      return [] if @user != current_user
      budgets_current = Budget.includes(:investments).where(phase: 'selecting')
      investment_ids = budgets_current.map { |b| b.investment_ids }.flatten
      @votes = @user.votes.for_type(Budget::Investment).where(votable_id: investment_ids)
    end

    def load_ballot_lines
      return [] if @user != current_user
      @ballot_lines = Budget::Ballot.includes(:lines).where(user_id: @user.id).last.lines
      # @ballot_lines = @user.votes.for_type(Budget::Investment).where(votable_id: investment_ids)
    end

    def load_proposals
      @proposals = Proposal.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

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
      @user.public_activity || authorized_current_user?
    end

    def valid_interests_access?
      @user.public_interests || authorized_current_user?
    end

    def valid_interests_access?(user)
      user.public_interests || user == current_user
    end

    def author?(proposal)
      proposal.author_id == current_user.id if current_user
    end
