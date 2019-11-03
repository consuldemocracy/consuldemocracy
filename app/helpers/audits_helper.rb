module AuditsHelper
  def truncate_audit_value(resource, field, value)
    if value.is_a?(Array)
      truncate(value.join(","), length: 50)
    elsif resource.type_for_attribute(field.to_s).type == :boolean
      resource.class.human_attribute_name("#{field}_#{value}")
    else
      truncate(value.to_s, length: 50)
    end
  end
end
