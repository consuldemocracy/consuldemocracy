module AdminHelper

  def side_menu
    render "/#{namespace}/menu"
  end

  def official_level_options
    options = [["",0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), Setting.value_for("official_level_#{i}_name")].compact.join(': '), i]
    end
    options
  end

  private

    def namespace
      controller.class.parent.name.downcase
    end

end