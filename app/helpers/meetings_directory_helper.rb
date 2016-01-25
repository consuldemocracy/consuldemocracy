module MeetingsDirectoryHelper
  def meetings_directory(options = {})
    react_component(
      'MeetingsDirectory', 
      filter: options[:filter],
      meetings: serialized_meetings(options[:meetings]),
      districts: Proposal::DISTRICTS,
      categories: serialized_categories,
      subcategories: serialized_subcategories
    )
  end

  def serialized_meetings(meetings)
    meetings.map do |meeting|
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
  end
end
