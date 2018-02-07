namespace :initial_modules do

  desc "Set initials modules"
  task set_module: :environment do
    # Feature flags
    Setting['feature.debates'] = false
    Setting['feature.proposals'] = true
    Setting['feature.spending_proposals'] = false
    Setting['feature.polls'] = false
    Setting['feature.twitter_login'] = false
    Setting['feature.facebook_login'] = false
    Setting['feature.google_login'] = false
    Setting['feature.public_stats'] = false
    Setting['feature.budgets'] = false
    Setting['feature.signature_sheets'] = false
    Setting['feature.legislation'] = false
    Setting['feature.user.recommendations'] = false
    Setting['feature.community'] = false
    Setting['feature.map'] = nil
    Setting['feature.allow_images'] = true
    Setting['feature.guides'] = nil
  end

end
