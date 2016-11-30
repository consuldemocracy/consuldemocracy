require 'rails_helper'

describe GraphQL::TypeCreator do
  let(:type_creator) { GraphQL::TypeCreator.new }

  #let(:api_types) { {} }
  #let!(:user_type)    { GraphQL::TypeCreator.create(User, %I[ id ], api_types) }
  #let!(:comment_type) { GraphQL::TypeCreator.create(Comment, %I[ id ], api_types) }
  #let!(:debate_type)  { GraphQL::TypeCreator.create(Debate, %I[ id title author ], api_types) }
  # TODO: no puedo añadir los comentarios a la field_list de Debate porque como
  # las conexiones se crean de forma lazy creo que provoca que falle la creación
  # del resto de tipos y provoca que fallen todos los tests.
  # let!(:debate_type)  { GraphQL::TypeCreator.create(Debate, %I[ id title author comments ], api_types) }

  describe "::create" do
    describe "creates fields" do
      it "for int attributes" do
        debate_type = type_creator.create(Debate, %I[ id ])
        created_field = debate_type.fields['id']

        expect(created_field).to be_a(GraphQL::Field)
        expect(created_field.type).to be_a(GraphQL::ScalarType)
        expect(created_field.type.name).to eq('Int')
      end

      it "for string attributes" do
        skip
        created_field = debate_type.fields['title']

        expect(created_field).to be_a(GraphQL::Field)
        expect(created_field.type).to be_a(GraphQL::ScalarType)
        expect(created_field.type.name).to eq('String')
      end
    end

    describe "creates connections for" do
      it ":belongs_to associations" do
        user_type = type_creator.create(User, %I[ id ])
        debate_type = type_creator.create(Debate, %I[ author ])

        connection = debate_type.fields['author']

        # TODO: because connection types are created and added  lazily to the
        # api_types hash (with that proc thing ->) I don't really know how to
        # test this.
        # connection.class shows GraphQL::Field
        # connection.inspect shows some weird info

        expect(connection).to be_a(GraphQL::Field)
        #debugger
        expect(connection.type).to eq(user_type)
        expect(connection.name).to eq('author')
      end

      it ":has_one associations" do
        skip "need to find association example that uses :has_one"
      end

      it ":has_many associations" do
        #skip "still don't know how to handle relay connections inside RSpec"
        comment_type = type_creator.create(Comment, %I[ id ])
        debate_type = type_creator.create(Debate, %I[ author ])

        connection = debate_type.fields['comments']

        # TODO: because connection types are created and added  lazily to the
        # api_types hash (with that proc thing ->) I don't really know how to
        # test this.
        # connection.class shows GraphQL::Field
        # connection.inspect shows some weird info

        expect(connection).to be_a(GraphQL::Field)
        expect(connection.type).to be_a(api_types[Comment])
        expect(connection.name).to eq('comments')
      end
    end
  end
end
