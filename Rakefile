# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

Rails.application.load_tasks if Rake::Task.tasks.empty?

if Rails.env.development?
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.user = "consul"
    config.project = "consul"
    config.since_tag = "1.4.1"
    config.future_release = "1.5.0"
    config.base = "#{Rails.root}/CHANGELOG.md"
    config.token = Rails.application.secrets.github_changelog_token
    config.issues = false
    config.author = false
  end
end
