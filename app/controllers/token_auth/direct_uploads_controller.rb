# DirectUploadsController, but Authentication happens via token
# used in combination with graphql-api
class TokenAuth::DirectUploadsController < DirectUploadsController
  include DeviseTokenAuth::Concerns::SetUserByToken
  skip_before_action :verify_authenticity_token
  skip_authorization_check
end
