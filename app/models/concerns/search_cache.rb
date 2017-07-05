module SearchCache
  extend ActiveSupport::Concern

  included do
    after_save :calculate_tsvector
  end

  def calculate_tsvector
    ActiveRecord::Base.connection.execute("
      UPDATE #{self.class.table_name} SET tsv = (#{searchable_values_sql}) WHERE id = #{id}")
  end

  private

  def searchable_values_sql
    searchable_values
      .select{ |k, _| k.present? }
      .collect{ |value, weight| set_tsvector(value, weight) }
      .join(" || ")
  end

  def set_tsvector(value, weight)
    "setweight(to_tsvector('spanish', unaccent(coalesce(#{quote(strip_html(value))}, ''))), #{quote(weight)})"
  end

  def quote(value)
    ActiveRecord::Base.connection.quote(value)
  end

  def strip_html(value)
    ActionController::Base.helpers.sanitize(value, tags: [])
  end

end
