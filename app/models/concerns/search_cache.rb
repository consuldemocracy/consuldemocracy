module SearchCache
  extend ActiveSupport::Concern

  included do
    after_save :calculate_tsvector
  end

  def calculate_tsvector
    ActiveRecord::Base.connection.execute("
      UPDATE proposals SET tsv = (to_tsvector('spanish', #{fields_to_sql})) WHERE id = #{self.id}")
  end

  def fields_to_sql
    fields.collect { |field| "coalesce(#{field},'')" }.join(" || ' ' || ")
  end

  def fields
    searchable_fields << tags_to_sql
  end

  def tags_to_sql
    "\'#{tag_list.join(' ')}\'"
  end

end