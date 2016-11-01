module TracksHelper
  def track_event(category, action, name=nil)
    content_for :track_event_category do
      category
    end

    content_for :track_event_action do
      action
    end

    content_for :track_event_name do
      name
    end
  end
end