class Widgets::Feeds::FeedComponent < ApplicationComponent
  attr_reader :feed
  delegate :kind, to: :feed

  def initialize(feed)
    @feed = feed
  end

  def see_all_path
    polymorphic_path(feed.items.model)
  end

  private

    def item_component_class
      case kind
      when "proposals"
        Widgets::Feeds::ProposalComponent
      when "debates"
        Widgets::Feeds::DebateComponent
      when "processes"
        Widgets::Feeds::ProcessComponent
      end
    end
end
