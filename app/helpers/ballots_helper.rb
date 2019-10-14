module BallotsHelper

  def progress_bar_width(amount_available, amount_spent)
    (amount_spent/amount_available.to_f * 100).to_s + "%"
  end

  def total_steps(ballot, group)
    group.headings.count  + 1
  end

  def completed_steps(ballot, group)
    group.headings.select { |heading| ballot.number_remaining_lines_to_complete(heading) == 0 }.count + (ballot.confirmed? ? 1 : 0)
  end

  def headings_with_status(ballot, group, current_heading)
    group.headings.collect do |heading|
      {
          link: link_to(heading.name.truncate(26), budget_ballot_path(ballot.budget, heading_id: heading.id, group_id: group.id), title: heading.name),
          management_link: link_to(heading.name.truncate(26), management_budget_ballot_path(ballot.budget, ballot.id, heading_id: heading.id, group_id: group.id), title: heading.name),
          name: heading.name.truncate(26),
          pending: ballot.number_remaining_lines_to_complete(heading) > 0,
          remaining_count: ballot.number_remaining_lines_to_complete(heading),
          current: current_heading == heading
      }
    end
  end

  def inline_pending_groups(ballot, group)
    pending = group.headings.select { |heading| ballot.number_remaining_lines_to_complete(heading) > 0 }
    links = pending.collect do |heading|
        content_tag(:strong, "#{@ballot.number_remaining_lines_to_complete(heading)} #{link_to(heading.name, budget_ballot_path(ballot.budget, heading_id: heading.id, group_id: group.id)).html_safe}".html_safe)
    end

    links.join(' y ')
  end

  def inline_pending_groups_management(ballot, group)
    pending = group.headings.select { |heading| ballot.number_remaining_lines_to_complete(heading) > 0 }
    links = pending.collect do |heading|
      content_tag(:strong, "#{@ballot.number_remaining_lines_to_complete(heading)} #{link_to(heading.name, management_budget_ballot_path(ballot.budget, ballot, heading_id: heading.id, group_id: group.id)).html_safe}".html_safe)
    end

    links.join(' y ')
  end

  def inline_mandatory_groups(ballot, group)
    pending = group.headings
    links = pending.collect do |heading|
      content_tag(:strong, "#{@ballot.number_of_mandatory_lines_to_complete(heading)} #{link_to(heading.name, budget_ballot_path(ballot.budget, heading_id: heading.id, group_id: group.id)).html_safe}".html_safe)
    end

    links.join(' y ')
  end
end