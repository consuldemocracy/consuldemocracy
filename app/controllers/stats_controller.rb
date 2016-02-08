class StatsController < ApplicationController
  include FeatureFlags

  feature_flag :public_stats

  skip_authorization_check

  def index
    @visits = Visit.count
    @debates = Debate.with_hidden.count
    @proposals = Proposal.with_hidden.count
    @comments = Comment.with_hidden.count

    @debate_votes = Vote.where(votable_type: 'Debate').count
    @proposal_votes = Vote.where(votable_type: 'Proposal').count
    @comment_votes = Vote.where(votable_type: 'Comment').count
    @votes = Vote.count

    @verified_users = User.with_hidden.level_two_or_three_verified.count
    @unverified_users = User.with_hidden.unverified.count
  end
end
