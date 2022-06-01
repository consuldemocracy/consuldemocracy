class GraphqlController < ApplicationController
  include FeatureFlags

  feature_flag :graphql_api

  skip_before_action :verify_authenticity_token
  skip_authorization_check

  class QueryStringError < StandardError; end

  def execute
    begin
      raise GraphqlController::QueryStringError if query_string.nil?

      result = ConsulSchema.execute(query_string,
        variables: prepare_variables,
        context: {},
        operation_name: params[:operationName]
      )
      render json: result
    rescue GraphqlController::QueryStringError
      render json: { message: "Query string not present" }, status: :bad_request
    rescue JSON::ParserError
      render json: { message: "Error parsing JSON" }, status: :bad_request
    rescue GraphQL::ParseError
      render json: { message: "Query string is not valid JSON" }, status: :bad_request
    rescue ArgumentError => e
      render json: { message: e.message }, status: :bad_request
    end
  end

  private

    def query_string
      if request.headers["CONTENT_TYPE"] == "application/graphql"
        request.body.string
      else
        params[:query]
      end
    end

    # Handle variables in URL query string and JSON body
    def prepare_variables
      case variables_param = params[:variables]
      # URL query string
      when String
        if variables_param.present?
          JSON.parse(variables_param) || {}
        else
          {}
        end
      # JSON object in request body gets converted to ActionController::Parameters
      when ActionController::Parameters
        variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{variables_param}"
      end
    end
end
