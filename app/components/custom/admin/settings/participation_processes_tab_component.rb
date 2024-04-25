class Admin::Settings::ParticipationProcessesTabComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "admin", "settings", "participation_processes_tab_component").to_s

class Admin::Settings::ParticipationProcessesTabComponent
  def show_navbar_settings
    %w[
      show_navbar.debates
      show_navbar.proposals
      show_navbar.polls
      show_navbar.budgets
      show_navbar.legislation
      show_navbar.sdg
      show_navbar.help
    ]
  end
end
