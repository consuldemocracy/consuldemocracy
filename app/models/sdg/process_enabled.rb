class SDG::ProcessEnabled
  include SettingsHelper
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def enabled?
    feature?("sdg") && feature?(process_name) && setting["sdg.process.#{process_name}"]
  end

  private

    def process_name
      if module_name == "Legislation"
        "legislation"
      else
        module_name.constantize.table_name
      end
    end

    def module_name
      name.split("::").first
    end
end
