class LdapController < ApplicationController
  skip_authorization_check only: [:new, :create]

  def new; end

  def create
    redirect_to controller: "users/omniauth_callbacks",
                action: "ldap",
                username: request["username"],
                password: request["password"]
  end
end
