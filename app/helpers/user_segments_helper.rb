module UserSegmentsHelper
  def user_segments_options
    UserSegments::SEGMENTS.collect do |user_segment_name|
      [t("admin.segment_recipient.#{user_segment_name}"), user_segment_name]
    end
  end
end
