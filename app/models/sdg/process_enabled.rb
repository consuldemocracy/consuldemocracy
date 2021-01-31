class SDG::ProcessEnabled
  include SettingsHelper
  attr_reader :record_or_name

  def initialize(record_or_name)
    @record_or_name = record_or_name
  end

  def enabled?
    feature?("sdg") && feature?(process_name) && setting["sdg.process.#{process_name}"] && relatable?
  end

  def name
    if record_or_name.respond_to?(:downcase)
      record_or_name
    else
      record_or_name.class.name
    end
  end

  private

    def process_name
      if controller_path_name?
        name.split("/").first
      else
        if module_name == "Legislation"
          "legislation"
        else
          module_name.constantize.table_name
        end
      end
    end

    def controller_path_name?
      name == name.downcase
    end

    def module_name
      name.split("::").first
    end

    def relatable?
      return true if controller_path_name?

      (SDG::Related::RELATABLE_TYPES & [record_or_name.class.name, record_or_name]).any?
    end
end
