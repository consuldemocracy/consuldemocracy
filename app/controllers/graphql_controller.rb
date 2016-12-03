class GraphqlController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def query

    if request.headers["CONTENT_TYPE"] == 'application/graphql'
      query_string = request.body.string  # request.body.class => StringIO
    else
      query_string = params[:query]
    end

    if query_string.nil?
      render json: { message: 'Query string not present' }, status: :bad_request
    else
      begin
        response = ConsulSchema.execute(
          query_string,
          variables: params[:variables] || {}
        )
        render json: response, status: :ok
      rescue GraphQL::ParseError
        render json: { message: 'Query string is not valid JSON' }, status: :bad_request
      end
    end
  end
end
