module Tags
  # spec/models/tag_cloud_spec.rb
  def tag_names(tag_cloud)
    tag_cloud.tags.map(&:name)
  end
end
