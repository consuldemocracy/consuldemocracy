module MeetingsDirectoryHelper
  def meetings_directory(options = {})
    meetings = options[:meetings].map do |meeting|
      {
        id: meeting.id,
        title: meeting.title,
        description: meeting.description,
        address: meeting.address,
        address_latitude: meeting.address_latitude,
        address_longitude: meeting.address_longitude,
        held_at: l(meeting.held_at),
        start_at: l(meeting.start_at),
        end_at: l(meeting.end_at),
        url: meeting_url(meeting)
      }
    end
    react_component 'MeetingsDirectory', meetings: meetings
  end
end
