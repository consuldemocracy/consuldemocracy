class Admin::Settings::ParticipationProcessesTabComponent < ApplicationComponent
  def settings
    %w[
      process.debates
      process.proposals
      process.polls
      process.budgets
      process.legislation
    ]
  end
end
