require_dependency "#{Rails.root}/app/controllers/budgets/executions_controller"

Budgets::ExecutionsController.class_eval do
  private
    def investments_by_heading_ordered_alphabetically
      investments_by_heading_ordered_alphabetically_with_city_heading_first
    end

    def investments_by_heading_ordered_alphabetically_with_city_heading_first
      investments_by_heading.sort do |a, b|
        if a[0].city_heading?
          -1
        elsif b[0].city_heading?
          1
        else
          a[0].name <=> b[0].name
        end
      end
    end
end
