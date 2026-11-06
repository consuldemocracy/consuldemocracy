class Budgets::Groups::ShowComponent < ApplicationComponent
  attr_reader :group
  delegate :image_path_for, to: :helpers

  def initialize(group)
    @group = group
  end

  private

    def budget
      @group.budget
    end

    def css_for_ballot_heading(heading)
      current_ballot&.has_lines_in_heading?(heading) ? "is-active" : ""
    end

    def current_ballot
      Budget::Ballot.find_by(user: current_user, budget: budget) if current_user
    end
end
