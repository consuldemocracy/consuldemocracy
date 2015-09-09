class Ahoy::Store < Ahoy::Stores::ActiveRecordStore

  def track_visit(options)
    StatsJob.perform_later(super, name: "visit")
  end

  # Track user IP
  def track_event(name, properties, options)
    StatsJob.perform_later(super { |event| event.ip = request.ip }, name: "event")
  end
end