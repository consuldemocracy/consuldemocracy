class Account::VerifyAccountComponent < ApplicationComponent
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def render?
    Setting["feature.user.skip_verification"].blank? && !account.organization?
  end
end
