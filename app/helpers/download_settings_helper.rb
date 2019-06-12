module DownloadSettingsHelper

  def get_model(resource_name)
    case resource_name
    when "legislation_processes"
      Legislation::Process
    when "budget_investments"
      Budget::Investment
    else
      resource_name.singularize.classify.constantize
    end
  end

  def get_attrs(model, config = 0)
    download_settings = []
    get_attr_names(model).each do |attr_name|
      download_settings << DownloadSetting.initialize(model, attr_name, config)
    end
    download_settings
  end

  def get_attr_names(model)
    model.attribute_names + model.get_association_attribute_names
  end

  def to_csv(resources_csv, resource_model, config = 0)
    attribute_csv = resource_model.get_downloadables_names(config)
    if admin_downloables?
      attribute_csv = params[:downloadable]
    end
    resource_model.to_csv(resources_csv, attribute_csv)
  end

  def admin_downloables?
    params[:downloadable].present? && !params[:downloadable].empty?
  end

  def get_resource(resource)

    resource.to_s.pluralize.downcase
  end

  def get_config
    params[:config].present? && !params[:config].nil? ? params[:config] : 0
  end

end
