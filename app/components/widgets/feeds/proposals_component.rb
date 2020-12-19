class Widgets::Feeds::ProposalsComponent < ApplicationComponent
  include FeedsHelper
  attr_reader :feed

  def initialize(feed)
    @feed = feed
  end
end
