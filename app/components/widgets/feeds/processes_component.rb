class Widgets::Feeds::ProcessesComponent < ApplicationComponent
  attr_reader :feed

  def initialize(feed)
    @feed = feed
  end
end
