class Proposals::NewComponent < ApplicationComponent
  include Header
  attr_reader :proposal
  delegate :new_window_link_to, to: :helpers

  def initialize(proposal)
    @proposal = proposal
  end

  def title
    t("proposals.new.start_new")
  end
end
