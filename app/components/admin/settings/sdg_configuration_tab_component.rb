class Admin::Settings::SDGConfigurationTabComponent < ApplicationComponent
  def settings
    %w[
      sdg.process.debates
      sdg.process.proposals
      sdg.process.polls
      sdg.process.budgets
      sdg.process.legislation
    ]
  end
end
