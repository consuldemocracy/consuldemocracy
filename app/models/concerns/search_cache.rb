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
    cx = ActiveRecord::Base.connection
    arr = []
    searchable_values.each do |val, weight|
      if val.present?
        arr << "setweight(to_tsvector('spanish', coalesce(#{cx.quote(val)}, '')), #{cx.quote(weight)})"
      end
    end
    arr.join(" || ")
  end

end
