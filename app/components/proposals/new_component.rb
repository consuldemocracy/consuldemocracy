class Proposals::NewComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end
end
