class SDGManagement::Targets::IndexComponent < ApplicationComponent
  include Header

  attr_reader :targets

  def initialize(targets)
    @targets = targets
  end

  private

    def title
      SDG::Target.model_name.human(count: 2).titleize
    end

    def attribute_name(attribute)
      SDG::Target.human_attribute_name(attribute)
    end

    def header_id(object)
      "#{dom_id(object)}_header"
    end
end
