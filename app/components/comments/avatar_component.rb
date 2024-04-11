class Comments::AvatarComponent < ApplicationComponent
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end

  private

    def special_avatar(image_name, options = {})
      image_tag(image_name, { size: 32, alt: "" }.merge(options))
    end
end
