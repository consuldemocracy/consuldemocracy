class Proposals::FeaturedProposalsComponent < ApplicationComponent
  attr_reader :proposals

  def initialize(proposals)
    @proposals = proposals
  end

  def render?
    params[:selected].blank? && proposals.present?
  end
end
