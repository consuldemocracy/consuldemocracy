class Proposals::NewComponent < ApplicationComponent
  include Header
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def title
    t("proposals.new.start_new")
  end
end
