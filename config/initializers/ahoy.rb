class Ahoy::Store < Ahoy::Stores::ActiveRecordStore

  def track_visit(options)
    StatsJob.perform_later(super)
  end

  # Track user IP
  def track_event(name, properties, options)
    super do |event|
      event.ip = request.ip
    end
  end
end