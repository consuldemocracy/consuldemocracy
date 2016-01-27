class TagCloud

  attr_accessor :resource_model

  def initialize(resource_model)
    @resource_model = resource_model
  end

  def tags
    resource_model.last_week.tag_counts.order("#{resource_model.to_s.downcase.pluralize}_count": :desc, name: :asc).limit(5)
  end

end