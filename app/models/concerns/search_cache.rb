module SearchCache
  extend ActiveSupport::Concern

  included do
    after_save :calculate_tsvector
  end

  def calculate_tsvector
    self.class.where(id: id).update_all("tsv = (#{searchable_values_sql})")
  end

  private

    def searchable_values_sql
      searchable_values
        .select { |k, _| k.present? }
        .map { |value, weight| set_tsvector(value, weight) }
        .join(" || ")
    end

    def set_tsvector(value, weight)
      dict = quote(SearchDictionarySelector.call)
      "setweight(to_tsvector(#{dict}, unaccent(coalesce(#{quote(strip_html(value))}, ''))), #{quote(weight)})"
    end

    def quote(value)
      ActiveRecord::Base.connection.quote(value)
    end

    def strip_html(value)
      ActionController::Base.helpers.sanitize(value, tags: [])
    end
end
