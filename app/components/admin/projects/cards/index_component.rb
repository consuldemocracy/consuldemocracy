class Admin::Projects::Cards::IndexComponent < ApplicationComponent
  include Header
  attr_reader :project, :cards

  def initialize(project, cards)
    @project = project
    @cards = cards
  end

end
