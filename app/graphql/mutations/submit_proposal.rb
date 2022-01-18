module Mutations
  class SubmitProposal < BaseMutation
    argument :title, String, required: true, validates: { allow_blank: false }
    argument :description, String, required: true, validates: { allow_blank: false }
    argument :summary, String, required: true, validates: {
      length: { maximum: 200 },
      allow_blank: false
    }
    argument :terms_of_service, Boolean, required: true

    argument :geozone_id, ID, required: false
    argument :video_url, String, required: false
    argument :tag_list, String, required: false

    # TODO: Add file uploads

    type Types::ProposalType

    def resolve(title:, description:, summary:, terms_of_service:, geozone_id: nil, video_url: nil, tag_list: nil)
      begin
        Proposal.create!({
          # TODO: Add map feature
          # map_location_attributes: {
          #   latitude: "",
          #   longitude: "",
          #   zoom:""
          # },
          translations_attributes: {
            '0': {
              locale: context[:current_resource].locale,
              title: title,
              description: description,
              summary: summary
            }
          },
          terms_of_service: terms_of_service,
          geozone_id: geozone_id,
          tag_list: tag_list,
          video_url: video_url,
          author: context[:current_resource]
        })
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
