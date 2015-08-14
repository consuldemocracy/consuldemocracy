module AdminHelper

  def namespace
    controller.class.parent.name.downcase
  end

end