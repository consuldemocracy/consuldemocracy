class Widgets::Feeds::ProposalsComponent < ApplicationComponent
  attr_reader :feed

  def initialize(feed)
    @feed = feed
  end
end
