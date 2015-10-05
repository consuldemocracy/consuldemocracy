module AdminHelper

  def side_menu
    #render "/#{namespace}/menu"
  end

  def official_level_options
    options = [["",0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), Setting.value_for("official_level_#{i}_name")].compact.join(': '), i]
    end
    options
  end

  def humanize_document_type(document_type)
    case document_type
    when "1"
      t "verification.residence.new.document_type.spanish_id"
    when "2"
      t "verification.residence.new.document_type.passport"
    when "3"
      t "verification.residence.new.document_type.residence_card"
    end
  end

  private

    def namespace
      controller.class.parent.name.downcase
    end

end