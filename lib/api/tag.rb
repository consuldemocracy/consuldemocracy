class API::Tag

  attr_accessor :tag

  def initialize(id)
    @tag = ::Tag.find(id)
  end

  def self.public_columns
    ["name",
     "taggings_count",
     "kind"]
  end

  def public_attributes
    tag.attributes.values_at(*API::Tag.public_columns)
  end

  def public?
    [nil, "category"].include? tag.kind
  end

end

# * COMPROBAR campo “kind”. Se incluyen las tags con valor nil ó category (nil son las etiquetas normales y category las que marcamos como etiquetas por defecto para poner en las propuestas)