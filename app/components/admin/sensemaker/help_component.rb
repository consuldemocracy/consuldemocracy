class Admin::Sensemaker::HelpComponent < ApplicationComponent
  def scripts
    Sensemaker::ScriptRegistry.all
  end

  def script_title(script)
    key = Sensemaker::ScriptRegistry.i18n_key(script)
    t("admin.sensemaker.scripts.#{key}.title")
  end

  def script_description(script)
    key = Sensemaker::ScriptRegistry.i18n_key(script)
    t("admin.sensemaker.scripts.#{key}.description")
  end
end
