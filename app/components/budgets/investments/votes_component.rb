class Budgets::Investments::VotesComponent < ApplicationComponent
  attr_reader :investment, :investment_votes, :vote_url
  delegate :current_user, :voted_for?, :image_absolute_url,
    :link_to_verify_account, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(investment, investment_votes:, vote_url:)
    @investment = investment
    @investment_votes = investment_votes
    @vote_url = vote_url
  end

  private

    def reason
      @reason ||= investment.reason_for_not_being_selectable_by(current_user)
    end

    def voting_allowed?
      reason != :not_voting_allowed
    end

    def user_voted_for?
      @user_voted_for ||= voted_for?(investment_votes, investment)
    end

    def display_support_alert?
      current_user &&
        !current_user.voted_in_group?(investment.group) &&
        investment.group.headings.count > 1
    end

    def confirm_vote_message
      t("budgets.investments.investment.confirm_group", count: investment.group.max_votable_headings)
    end

    def support_aria_label
      t("budgets.investments.investment.support_label", investment: investment.title)
    end
end
