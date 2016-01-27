class TagCloud

  attr_accessor :resource_model

  def initialize(resource_model)
    @resource_model = resource_model
  end

  def tags
    resource_model.last_week.tag_counts.
    where("lower(name) NOT IN (?)", category_names + geozone_names + default_blacklist)
    order("#{table_name}_count": :desc, name: :asc).
    limit(5)
  end

  def category_names
    ActsAsTaggableOn::Tag.where("kind = 'category'").map {|tag| tag.name.downcase }
  end

  def geozone_names
    Geozone.all.map {|geozone| geozone.name.downcase }
  end

  def default_blacklist
    ['']
  end

  def table_name
    resource_model.to_s.downcase.pluralize
  end

end