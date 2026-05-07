class Admin::Sensemaker::IndexComponent < ApplicationComponent
  include Header

  attr_reader :sensemaker_jobs, :running_jobs, :filter_target,
              :filter_resource_type, :filter_resource_id, :filter_resource_type_options

  def initialize(sensemaker_jobs, running_jobs, filter_target: nil,
                 filter_resource_type: nil, filter_resource_id: nil, filter_resource_type_options: [])
    @sensemaker_jobs = sensemaker_jobs
    @running_jobs = running_jobs
    @filter_target = filter_target
    @filter_resource_type = filter_resource_type
    @filter_resource_id = filter_resource_id
    @filter_resource_type_options = filter_resource_type_options || []
  end

  def title
    t("admin.sensemaker.index.title")
  end

  def enabled?
    Sensemaker.enabled?
  end

  def target_specified?
    filter_target.present?
  end

  def filter_active?
    filter_target.present? || filter_resource_type.present?
  end

  def filter_description
    return filter_target_name if filter_target.present?
    return t("admin.sensemaker.index.resource_types.#{filter_resource_type}") if filter_resource_type.present?

    nil
  end

  def filter_target_name
    return nil unless filter_target

    if filter_target.respond_to?(:title) && filter_target.title.present?
      filter_target.title
    elsif filter_target.respond_to?(:name) && filter_target.name.present?
      filter_target.name
    elsif filter_target.respond_to?(:value) && filter_target.value.present?
      filter_target.value
    else
      "##{filter_target.id}"
    end
  end
end
