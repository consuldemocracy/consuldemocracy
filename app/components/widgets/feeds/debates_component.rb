class Widgets::Feeds::DebatesComponent < ApplicationComponent
  attr_reader :feed

  def initialize(feed)
    @feed = feed
  end
end
