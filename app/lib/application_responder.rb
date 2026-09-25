class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  def default_render
    if post? && !has_errors?
      controller.render({ status: :created }.merge!(options))
    else
      super
    end
  end

  def api_behavior
    raise MissingRenderer.new(format) unless has_renderer?

    if get? || post?
      super
    else
      display resource, status: :ok
    end
  end
end
