module PhysicalFinalVotesHelper
  def physical_final_votes_advanced_filters(params)
    params.map { |af| t("admin.physical_final_votes.index.filters.#{af}") }.join(", ")
  end

  def link_to_physical_final_votes_sorted_by(column)
    direction = set_direction(params[:direction])
    icon = set_sorting_icon(direction, column)

    translation = t("admin.physical_final_votes.index.list.#{column}")

    link_to(
      safe_join([translation, content_tag(:span, "", class: "icon-sortable #{icon}")]),
      admin_physical_final_votes_path(sort_by: column, direction: direction)
    )
  end

  def set_sorting_icon(direction, sort_by)
    if sort_by.to_s == params[:sort_by]
      if direction == "desc"
        "desc"
      else
        "asc"
      end
    else
      ""
    end
  end

  def set_direction(current_direction)
    current_direction == "desc" ? "asc" : "desc"
  end

end
