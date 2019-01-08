module Tags
  def tag_names(tag_cloud)
    tag_cloud.tags.map(&:name)
  end
end
