class SDG::RelatedListSelectorComponent < ApplicationComponent
  attr_reader :f

  def initialize(form)
    @f = form
  end
end
