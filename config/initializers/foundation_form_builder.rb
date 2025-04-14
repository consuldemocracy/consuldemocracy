require Rails.root.join("vendor/foundation_rails_helper/form_builder.rb")

class FoundationRailsHelper::FormBuilder
  def column_classes(...)
    ""
  end

  def auto_labels
    true
  end

  def submit(value = nil, options = {})
    options[:class] ||= "success button"
    super
  end
end
