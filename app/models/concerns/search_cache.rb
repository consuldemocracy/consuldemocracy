module SearchCache
  extend ActiveSupport::Concern

  included do
    after_save :calculate_tsvector
  end

  def calculate_tsvector
    ActiveRecord::Base.connection.execute("
      UPDATE proposals SET tsv = (#{searchable_values_sql}) WHERE id = #{self.id}")
  end

  private

  def searchable_values_sql
    searchable_values.collect { |value, weight| set_tsvector(value, weight) }.join(" || ")
  end

  def set_tsvector(value, weight)
    "setweight(to_tsvector('#{dictionary_for_searches}', coalesce(#{quote(value)}, '')), #{quote(weight)})"
  end

  def quote(value)
    ActiveRecord::Base.connection.quote(value)
  end

end