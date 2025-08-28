class Dashboard::ResourcesComponent < ApplicationComponent
  attr_reader :proposal, :new_actions_since_last_login

  def initialize(proposal, new_actions_since_last_login = [])
    @proposal = proposal
    @new_actions_since_last_login = new_actions_since_last_login
  end

  private

    def default_resources
      %w[polls mailing poster]
    end

    def active_resources
      @active_resources ||= Dashboard::Action.active
                                             .resources
                                             .by_proposal(proposal)
                                             .order(required_supports: :asc, day_offset: :asc)
    end
end
