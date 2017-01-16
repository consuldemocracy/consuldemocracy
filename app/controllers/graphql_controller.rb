class GraphqlController < ApplicationController
  attr_accessor :query_variables, :query_string

  skip_before_action :verify_authenticity_token
  skip_authorization_check

  class QueryStringError < StandardError; end

  def query
    begin
      # ------------------------------------------------------------------------
      api_types_creator = GraphQL::ApiTypesCreator.new(API_TYPE_DEFINITIONS)
      created_api_types = api_types_creator.create

      query_type_creator = GraphQL::QueryTypeCreator.new(created_api_types)
      query_type = query_type_creator.create

      consul_schema = GraphQL::Schema.define do
        query query_type
        max_depth 12
      end
      # ------------------------------------------------------------------------
      set_query_environment
      response = consul_schema.execute query_string, variables: query_variables
      render json: response, status: :ok
    rescue GraphqlController::QueryStringError
      render json: { message: 'Query string not present' }, status: :bad_request
    rescue GraphQL::ParseError
      render json: { message: 'Query string is not valid JSON' }, status: :bad_request
    end
  end

  private

    def set_query_environment
      set_query_string
      set_query_variables
    end

    def set_query_string
      if request.headers["CONTENT_TYPE"] == 'application/graphql'
        @query_string = request.body.string  # request.body.class => StringIO
      else
        @query_string = params[:query]
      end
      if query_string.nil? then raise GraphqlController::QueryStringError end
    end

    def set_query_variables
      if params[:variables].blank?
        @query_variables = {}
      else
        @query_variables = JSON.parse(params[:variables])
      end
    end
end
