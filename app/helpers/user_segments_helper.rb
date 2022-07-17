module UserSegmentsHelper
  def user_segments_options
    UserSegments.segments.map do |user_segment_name|
      [segment_name(user_segment_name), user_segment_name]
    end
  end

  def segment_name(user_segment)
    UserSegments.segment_name(user_segment) || I18n.t("admin.segment_recipient.invalid_recipients_segment")
  end
end
