Audited.config do |config|
  config.audit_class = ::Audit
  config.ignored_default_callbacks = [:touch]
end
