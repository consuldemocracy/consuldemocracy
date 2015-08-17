module AdminHelper

  def side_menu
    render "/#{namespace}/menu"
  end

  def official_level_options
    1..5
  end

  private

    def namespace
      controller.class.parent.name.downcase
    end

end