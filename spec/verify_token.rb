# frozen_string_literal: true

module Mutations
  VerifyToken = GraphQL::ObjectType.define do
    field :verify_token, Types::VerifyType do
      argument :token, types.String
      argument :user_id, types.Int

      resolve ->(_obj, args, _ctx) do
        user = User.find(args[:user_id])
        response = user.verify_token(args[:token])
        if response.success
          user.update(number_validated_at: Time.zone.now)
          user
        else
          GraphQL::ExecutionError.new(response.message)
        end
      end
    end
  end
end
