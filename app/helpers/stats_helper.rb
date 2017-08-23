module StatsHelper

  def events_chart_tag(events, opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(events: events)
    content_tag :div, "", opt
  end

  def visits_chart_tag(opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(visits: true)
    content_tag :div, "", opt
  end

  def spending_proposals_chart_tag(opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(spending_proposals: true)
    content_tag :div, "", opt
  end

  def budget_investments_chart_tag(opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(budget_investments: true)
    content_tag :div, "", opt
  end

end
