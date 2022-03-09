module ImageablesHelper
  def can_destroy_image?(imageable)
    imageable.image.present? && can?(:destroy, imageable.image)
  end
end
