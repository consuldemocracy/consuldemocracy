class ExposableModel
  attr_reader :name, :description, :exposed_fields, :exposed_associations

  def initialize(model_class, options = {})
    @name = model_class.name
    @description = model_class.model_name.human
    @field_filter_list = options[:field_filter_list] || []
    @assoc_filter_list = options[:assoc_filter_list] || []
    @filter_strategy = options[:filter_strategy]
    set_exposed_items(model_class)
  end

  private

  # determine which model fields and associations are exposed to the API
  def set_exposed_items(model_class)
    @exposed_fields = check_against_safety_list(model_class.columns, @field_filter_list)
    @exposed_associations = check_against_safety_list(model_class.reflect_on_all_associations, @assoc_filter_list)
  end

  def check_against_safety_list(all_items, safety_list)
    case @filter_strategy
    when :whitelist
      exposed_items = all_items.select do |column|
        safety_list.include? column.name.to_s  # works for both symbols and strings
      end
    when :blacklist
      exposed_items = all_items.select do |column|
        !(safety_list.include? column.name.to_s)
      end
    else
      exposed_items = []
    end
  end

end
