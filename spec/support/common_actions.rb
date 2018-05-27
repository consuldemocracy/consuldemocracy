Dir["./spec/support/common_actions/*.rb"].each { |f| require f }

module CommonActions
  include Budgets
  include Comments
  include Debates
  include Emails
  include Notifications
  include Polls
  include Proposals
  include Tags
  include Users
  include Verifications
  include Votes
end
