class Comments::ActionsComponent < ApplicationComponent
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end
end
