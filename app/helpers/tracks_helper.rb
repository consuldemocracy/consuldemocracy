module TracksHelper
  def track_event(category, action)
    content_for :track_event_category do
      category
    end
    content_for :track_event_action do
      action
    end
  end
end