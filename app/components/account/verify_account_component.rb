class Account::VerifyAccountComponent < ApplicationComponent
  attr_reader :account

  def initialize(account)
    @account = account
  end
end
