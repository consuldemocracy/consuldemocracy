# TODO: Remove quiet_deps once we upgrade Foundation and Font Awesome,
# and remove silence_deprecations once we migrate away from Sass @import rules,
# which will be removed in Dart Sass 3.0.0.
SassC::Engine.class_eval do
  alias_method :original_initialize, :initialize

  def initialize(template, options = {})
    original_initialize(template, options.merge(quiet_deps: true, silence_deprecations: [:import]))
  end
end
