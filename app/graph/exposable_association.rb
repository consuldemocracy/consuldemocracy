class ExposableAssociation
  attr_reader :name, :type

  def initialize(association)
    @name = association.name
    @type = association.macro # :has_one, :belongs_to or :has_many
  end
end
