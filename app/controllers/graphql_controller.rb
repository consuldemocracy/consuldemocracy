class GraphqlController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_authorization_check

  class QueryStringError < StandardError; end

  def query
    begin
      if query_string.nil? then raise GraphqlController::QueryStringError end
      response = consul_schema.execute query_string, variables: query_variables
      render json: response, status: :ok
    rescue GraphqlController::QueryStringError
      render json: { message: 'Query string not present' }, status: :bad_request
    rescue GraphQL::ParseError
      render json: { message: 'Query string is not valid JSON' }, status: :bad_request
    end
  end

  private

    def consul_schema
      api_types = GraphQL::ApiTypesCreator.new(API_TYPE_DEFINITIONS).create
      query_type = GraphQL::QueryTypeCreator.new(api_types).create

      GraphQL::Schema.define do
        query query_type
        max_depth 12
      end
    end

    def query_string
      if request.headers["CONTENT_TYPE"] == 'application/graphql'
        request.body.string  # request.body.class => StringIO
      else
        params[:query]
      end
    end

    def query_variables
      params[:variables].blank? ? {} : JSON.parse(params[:variables])
    end
end
