module TopicsHelper

  def disabled_create_topic
    "disabled" unless current_user
  end

  def disabled_info_title
    t("community.show.sidebar.disabled_info_title") unless current_user
  end

end
