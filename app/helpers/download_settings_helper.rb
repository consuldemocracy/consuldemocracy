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

  def get_attrs(model)
    download_settings = []
    get_attr_names(model).each do |attr_name|
      download_settings << DownloadSetting.initialize(model, attr_name)
    end
    download_settings
  end

  def get_attr_names(model)
    model.attribute_names + model.get_association_attribute_names
  end

  def to_csv(resources)
    attributes = params[:downloadable].presence || resources.get_downloadables_names
    resources.to_csv(attributes)
  end
end
