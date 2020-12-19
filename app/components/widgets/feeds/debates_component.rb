class Widgets::Feeds::DebatesComponent < ApplicationComponent
  include FeedsHelper
  attr_reader :feed

  def initialize(feed)
    @feed = feed
  end
end
