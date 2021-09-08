module ActiveModel::Dates
  def parse_date(field, attrs)
    year, month, day = attrs["#{field}(1i)"], attrs["#{field}(2i)"], attrs["#{field}(3i)"]

    return nil unless day.present? && month.present? && year.present?

    Date.new(year.to_i, month.to_i, day.to_i)
  end

  def remove_date(field, attrs)
    attrs.except("#{field}(1i)", "#{field}(2i)", "#{field}(3i)")
  end
end
