class Comments::ActionsComponent < ApplicationComponent
  attr_reader :comment
  use_helpers :can?, :current_user

  def initialize(comment)
    @comment = comment
  end
end
