module GraphQLAPI
  def execute(query_string, context = {}, variables = {})
    ConsulSchema.execute(query_string, context: context, variables: variables)
  end

  def dig(response, path)
    response.dig(*path.split("."))
  end

  def extract_fields(response, collection_name, field_chain)
    fields = field_chain.split(".")
    dig(response, "data.#{collection_name}.edges").map do |node|
      if fields.size > 1
        node["node"][fields.first][fields.second]
      else
        node["node"][fields.first]
      end
    rescue NoMethodError
    end.compact
  end
end
