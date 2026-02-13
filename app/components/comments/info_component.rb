class Comments::InfoComponent < ApplicationComponent
  attr_reader :comment, :valuation

  def initialize(comment, valuation: false)
    @comment = comment
    @valuation = valuation
  end
end
