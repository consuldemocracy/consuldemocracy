class Legislation::BaseController < ApplicationController
  include FeatureFlags

  feature_flag :legislation

  def legislation_proposal_votes(proposals)
    @legislation_proposal_votes = current_user ? current_user.legislation_proposal_votes(proposals) : {}
  end

  def legislation_people_proposal_votes(people_proposals)
    @legislation_proposal_votes = {}
    if current_user
      @legislation_proposal_votes = current_user.legislation_people_proposal_votes(people_proposals)
    end
  end
end
