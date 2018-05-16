require_dependency Rails.root.join('app', 'models', 'tag_cloud').to_s

class TagCloud

  def tags
    resource_model_scoped.
    tag_counts.
    where("lower(name) NOT IN (?)", category_names + geozone_names + default_blacklist).
    order("#{table_name}_count": :desc, name: :asc).
    limit(10)
  end

end
