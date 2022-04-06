class TagCloud
  attr_accessor :resource_model, :scope

  def initialize(resource_model, scope = nil)
    @resource_model = resource_model
    @scope = scope
  end

  def tags
    resource_model_scoped.
    last_week.send(counts).
    where("lower(name) NOT IN (?)", category_names + geozone_names + default_blacklist).
    order("#{table_name}_count": :desc, name: :asc).
    limit(10)
  end

  def counts
    if Tag.machine_learning? && [Proposal, Budget::Investment].include?(resource_model)
      :ml_tag_counts
    else
      :tag_counts
    end
  end

  def category_names
    Tag.category_names.map(&:downcase)
  end

  def geozone_names
    Geozone.all.map { |geozone| geozone.name.downcase }
  end

  def resource_model_scoped
    scope && resource_model == Proposal ? resource_model.search(scope) : resource_model
  end

  def default_blacklist
    [""]
  end

  def table_name
    resource_model.to_s.tableize.tr("/", "_")
  end
end
