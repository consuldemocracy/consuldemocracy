require_dependency Rails.root.join("app", "models", "budget", "heading").to_s

class Budget
  class Heading < ApplicationRecord
    translates :long_name, touch: true

    def name_scoped_by_group
      group.single_heading_group? ? (long_name || name) : "#{group.name}: #{(long_name || name)}"
    end
  end
end
