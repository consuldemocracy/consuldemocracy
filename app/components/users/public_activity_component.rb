class Users::PublicActivityComponent < ApplicationComponent
  attr_reader :user
  delegate :current_user, :valid_interests_access?, :current_path_with_query_params, to: :helpers

  def initialize(user)
    @user = user
  end

  def valid_access?
    user.public_activity || authorized_current_user?
  end

  def current_filter
    if valid_filters.include?(params[:filter])
      params[:filter]
    else
      valid_filters.first
    end
  end

  def valid_filters
    @valid_filters ||= [
      ("proposals" if feature?(:proposals)),
      ("debates" if feature?(:debates)),
      ("budget_investments" if feature?(:budgets)),
      "comments",
      ("follows" if valid_interests_access?(user))
    ].compact.select { |filter| send(filter).any? }
  end

  private

    def authorized_current_user?
      current_user == user || current_user&.moderator? || current_user&.administrator?
    end

    def proposals
      Proposal.where(author_id: user.id)
    end

    def debates
      Debate.where(author_id: user.id)
    end

    def comments
      Comment.not_valuations
             .not_as_admin_or_moderator
             .where(user_id: user.id)
             .where.not(commentable_type: disabled_commentables)
             .includes(:commentable)
    end

    def budget_investments
      Budget::Investment.where(author_id: user.id)
    end

    def follows
      @follows ||= user.follows.select { |follow| follow.followable.present? }
    end

    def count(filter)
      send(filter).count
    end

    def render_user_partial(filter)
      render "users/#{filter}", "#{filter}": send(filter).order(created_at: :desc).page(page)
    end

    def page
      params[:page]
    end

    def disabled_commentables
      [
        ("Debate" unless feature?(:debates)),
        ("Budget::Investment" unless feature?(:budgets)),
        (["Legislation::Question",
          "Legislation::Proposal",
          "Legislation::Annotation"] unless feature?(:legislation)),
        (["Poll", "Poll::Question"] unless feature?(:polls)),
        ("Proposal" unless feature?(:proposals))
      ].flatten.compact
    end
end
