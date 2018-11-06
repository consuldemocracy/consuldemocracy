module UserSegmentsHelper
  def user_segments_options
    UserSegments::SEGMENTS.collect do |user_segment_name|
      [t("admin.segment_recipient.#{user_segment_name}"), user_segment_name]
    end
  end

  def segment_name(user_segment)
    if user_segment && UserSegments.respond_to?(user_segment)
      I18n.t("admin.segment_recipient.#{user_segment}")
    else
      I18n.t("admin.segment_recipient.invalid_recipients_segment")
    end
  end
end
