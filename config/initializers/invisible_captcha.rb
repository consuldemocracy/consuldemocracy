InvisibleCaptcha.setup do |config|
  # TODO: Actualmente no esta revisando si
  config.visual_honeypots        = false
  config.timestamp_threshold     = 4.seconds
  config.timestamp_enabled = true
  # Leave these unset if you want to use I18n (see below)
  # config.error_message           = 'You are a robot!'
  # config.sentence_for_humans     = 'If you are a human, ignore this field'
  # config.timestamp_error_message = 'Sorry, that was too quick! Please resubmit.'
end
