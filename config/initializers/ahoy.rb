Ahoy.geocode = false

class Ahoy::Store < Ahoy::Stores::ActiveRecordStore

  # Track user IP
  def track_event(name, properties, options)
    super do |event|
      event.user = nil
      event.ip = request.ip
    end
  end

  def track_visit(options)
    super do |visit|
      visit.user = nil
    end
  end

end
