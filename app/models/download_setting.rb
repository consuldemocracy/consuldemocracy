require "csv"

class DownloadSetting < ApplicationRecord
  validates :model, presence: true
  validates :field, presence: true

  def self.for(resource_name)
    model = model_for(resource_name)

    (model.attribute_names + author_attribute_names(model)).map do |field|
      where(model: model.name, field: field).first_or_create!
    end
  end

  def self.author_attribute_names(model)
    ["author_name", "author_email"].select { |field| model.attribute_method?(field) }
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

  def self.csv_for(resources, downloadable_attributes)
    attributes = downloadable_attributes.presence || downloadable_fields(resources)

    CSV.generate do |csv|
      csv << attributes
      resources.each do |resource|
        csv << attributes.map { |attr| resource.send(attr) }
      end
    end
  end

  def self.downloadable_fields(resources)
    where(model: resources.name, downloadable: true).pluck(:field)
  end

  def model_human_name
    model.constantize.model_name.human(count: 2)
  end

  def field_name
    model.constantize.human_attribute_name(field)
  end
end
