module Mutations
  class Register < GraphqlDevise::Mutations::Register
    argument :username, String, required: true
    argument :terms_of_service, Boolean, required: true

    field :user, Types::UserType, null: true

    def resolve(email:, **attrs)
      original_payload = super
      original_payload.merge(user: original_payload[:authenticatable])
    end
  end
end
