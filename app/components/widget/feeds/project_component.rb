class Widget::Feeds::ProjectComponent < ApplicationComponent
  attr_reader :project

  def initialize(project)
    @project = project
  end

  private

    def feed_active_projects?(feed)
      feed.kind == "active_projects"
    end

    def feed_archived_projects?(feed)
      feed.kind == "archived_projects"
    end
end
