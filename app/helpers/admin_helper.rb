module AdminHelper

  def side_menu
    render "/#{top_level_namespace}/menu"
  end

  def official_level_options
    options = [["",0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), Setting["official_level_#{i}_name"]].compact.join(': '), i]
    end
    options
  end

  private

    def top_level_namespace
      namespace.split(':').first
    end

    def namespace
      controller.class.parent.name.downcase
    end

end
