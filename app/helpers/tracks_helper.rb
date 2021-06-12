module TracksHelper
  def track_event(data = {})
    track_data = ""
    prefix = " data-track-event-"
    data.each do |key, value|
      track_data = "#{track_data}#{prefix}#{key}=#{value} "
    end
    content_for :track_event do
      track_data
    end
  end
end
