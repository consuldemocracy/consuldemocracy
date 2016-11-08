class ExposableModel
  attr_reader :exposed_fields, :name, :description

  def initialize(model_class, options = {})
    @model_class = model_class
    @filter_list = options[:filter_list] || []
    @name = model_class.name
    @description = model_class.model_name.human
    @filter_strategy = options[:filter_strategy]
    set_exposed_fields
  end

  private

  # determine which model fields are exposed to the API
  def set_exposed_fields
    case @filter_strategy
    when :whitelist
      @exposed_fields = @model_class.columns.select do |column|
        @filter_list.include? column.name
      end
    when :blacklist
      @exposed_fields = @model_class.columns.select do |column|
        !(@filter_list.include? column.name)
      end
    else
      @exposed_fields = []
    end
  end

end
