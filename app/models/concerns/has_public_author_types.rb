module HasPublicAuthorTypes
  def public_author_id_type
    GraphQL::INT_TYPE
  end

  def public_author_type
    TypeCreator.created_types[User]
  end
end
