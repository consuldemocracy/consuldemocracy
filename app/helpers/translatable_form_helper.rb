module TranslatableFormHelper
  def translatable_form_for(record, options = {}, &)
    form_for(record, options.merge(builder: TranslatableFormBuilder), &)
  end

  def translations_interface_enabled?
    Setting["feature.translation_interface"].present? || backend_translations_enabled?
  end

  def backend_translations_enabled?
    controller.class.module_parents.intersect?([Admin, Management, Valuation, SDGManagement])
  end

  def highlight_translation_html_class
    "highlight" if translations_interface_enabled?
  end
end
