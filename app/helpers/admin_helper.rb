module AdminHelper

  def side_menu
    render "/#{namespace}/menu"
  end

  private

    def namespace
      controller.class.parent.name.downcase
    end

end