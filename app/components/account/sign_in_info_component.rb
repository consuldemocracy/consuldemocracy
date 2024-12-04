class Account::SignInInfoComponent < ApplicationComponent
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def render?
    Tenant.current_secrets.dig(:security, :last_sign_in)
  end
end
