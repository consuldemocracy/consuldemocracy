class Proposals::NewComponent < ApplicationComponent
  include Header
  attr_reader :proposal
  use_helpers :new_window_link_to

  def initialize(proposal)
    @proposal = proposal
  end

  def title
    t("proposals.new.start_new")
  end
end
