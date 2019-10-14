module FoundationRailsHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    def cktext_area(attribute, options)
      field(attribute, options) do |opts|
        super(attribute, opts)
      end
    end
  end
end
