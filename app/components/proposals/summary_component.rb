class Proposals::SummaryComponent < ApplicationComponent
  attr_reader :proposals

  def initialize(proposals)
    @proposals = proposals
  end
end
