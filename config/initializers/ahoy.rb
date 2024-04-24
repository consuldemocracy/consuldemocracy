Ahoy.api = true
Ahoy.server_side_visits = :when_needed
Ahoy.mask_ips = true
Ahoy.cookies = :none

# Most code comes from:
# https://github.com/ankane/ahoy/blob/3661b7f9a/docs/Ahoy-2-Upgrade.md
class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(...)
  end

  def track_visit(data)
    data[:id] = ensure_uuid(data.delete(:visit_token))
    data[:visitor_id] = ensure_uuid(data.delete(:visitor_token))
    super(data)
  end

  def track_event(data)
    data[:id] = ensure_uuid(data.delete(:event_id))
    data[:ip] = request.ip
    super(data)
  end

  def visit
    unless defined?(@visit)
      if ahoy.send(:existing_visit_token) || ahoy.instance_variable_get(:@visit_token)
        @visit = visit_model.where(id: ensure_uuid(ahoy.visit_token)).take if ahoy.visit_token
      elsif !Ahoy.cookies? && ahoy.visitor_token
        @visit = visit_model.where(visitor_id: ensure_uuid(ahoy.visitor_token))
                            .where(started_at: Ahoy.visit_duration.ago..)
                            .order(started_at: :desc)
                            .first
      else
        @visit = nil
      end
    end

    @visit
  end

  def visit_model
    Visit
  end

  def ensure_uuid(id)
    UUIDTools::UUID.parse(id).to_s
  rescue
    UUIDTools::UUID.sha1_create(UUIDTools::UUID.parse(Ahoy::Tracker::UUID_NAMESPACE), id).to_s
  end

  def exclude?
    false
  end
end
