class Comments::AvatarComponent < ApplicationComponent
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end
end
