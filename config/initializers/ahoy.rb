Ahoy.geocode = false

class Ahoy::Store < Ahoy::Stores::ActiveRecordStore

  # Track user IP
  def track_event(name, properties, options)
    super do |event|
      event.user_id = nil
      event.ip = request.ip
    end
  end
end
