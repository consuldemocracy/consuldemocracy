class Proposals::SummaryComponent < ApplicationComponent
  attr_reader :proposals
  use_helpers :namespaced_proposal_path

  def initialize(proposals)
    @proposals = proposals
  end
end
