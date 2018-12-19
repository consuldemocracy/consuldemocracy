module Randomizable
  extend ActiveSupport::Concern

  class_methods do
    def sort_by_random(seed)
      ids = pluck(:id).shuffle(random: Random.new(seed))

      return all if ids.empty?

      ids_with_order = ids.map.with_index { |id, order| "(#{id}, #{order})" }.join(", ")

      joins("LEFT JOIN (VALUES #{ids_with_order}) AS ids(id, ordering) ON #{table_name}.id = ids.id")
        .order("ids.ordering")
    end

    alias_method :random, :sort_by_random
  end
end
