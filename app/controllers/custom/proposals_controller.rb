require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController < ApplicationController
  before_action :load_follow, only: :show

  private

    def load_follow
      @follow = Follow.find_or_initialize_by(user: current_user, followable: @proposal)
    end
end
