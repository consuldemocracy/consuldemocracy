class Admin::Projects::Phases::Cards::IndexComponent < ApplicationComponent
  include Header
  attr_reader :project_phase, :cards

  def initialize(project_phase, cards)
    @project_phase = project_phase
    @cards = cards
  end

end
