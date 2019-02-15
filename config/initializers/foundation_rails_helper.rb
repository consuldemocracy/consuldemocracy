module FoundationRailsHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    def cktext_area(attribute, options)
      field(attribute, options) do |opts|
        super(attribute, opts)
      end
    end

    def enum_select(attribute, options = {}, html_options = {})
      choices = object.class.send(attribute.to_s.pluralize).keys.map do |name|
        [object.class.human_attribute_name("#{attribute}.#{name}"), name]
      end

      select attribute, choices, options, html_options
    end
  end
end
