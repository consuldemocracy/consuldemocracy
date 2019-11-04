class DownloadSetting < ApplicationRecord
  validates :model, presence: true
  validates :field, presence: true

  def self.for(resource_name)
    model = model_for(resource_name)

    (model.attribute_names + model.get_association_attribute_names).map do |field|
      where(model: model.name, field: field).first_or_create!
    end
  end

  def self.model_for(resource_name)
    case resource_name
    when "legislation_processes"
      Legislation::Process
    when "budget_investments"
      Budget::Investment
    else
      resource_name.singularize.classify.constantize
    end
  end
end
