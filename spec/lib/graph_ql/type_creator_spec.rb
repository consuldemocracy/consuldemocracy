require 'rails_helper'

describe GraphQL::TypeCreator do
  let(:type_creator) { GraphQL::TypeCreator.new({}) }

  describe "::create_type" do
    it "creates fields for Int attributes" do
      debate_type = type_creator.create_type(Debate, { id: :integer })
      created_field = debate_type.fields['id']

      expect(created_field).to be_a(GraphQL::Field)
      expect(created_field.type).to be_a(GraphQL::ScalarType)
      expect(created_field.type.name).to eq('Int')
    end

    it "creates fields for String attributes" do
      debate_type = type_creator.create_type(Debate, { title: :string })
      created_field = debate_type.fields['title']

      expect(created_field).to be_a(GraphQL::Field)
      expect(created_field.type).to be_a(GraphQL::ScalarType)
      expect(created_field.type.name).to eq('String')
    end

    it "creates connections for :belongs_to associations" do
      user_type = type_creator.create_type(User, { id: :integer })
      debate_type = type_creator.create_type(Debate, { author: User })

      connection = debate_type.fields['author']

      expect(connection).to be_a(GraphQL::Field)
      expect(connection.type).to eq(user_type)
      expect(connection.name).to eq('author')
    end

    it "creates connections for :has_one associations" do
      user_type = type_creator.create_type(User, { organization: Organization })
      organization_type = type_creator.create_type(Organization, { id: :integer })

      connection = user_type.fields['organization']

      expect(connection).to be_a(GraphQL::Field)
      expect(connection.type).to eq(organization_type)
      expect(connection.name).to eq('organization')
    end

    it "creates connections for :has_many associations" do
      comment_type = type_creator.create_type(Comment, { id: :integer })
      debate_type = type_creator.create_type(Debate, { comments: [Comment] })

      connection = debate_type.fields['comments']

      expect(connection).to be_a(GraphQL::Field)
      expect(connection.type).to eq(comment_type.connection_type)
      expect(connection.name).to eq('comments')
    end
  end
end
