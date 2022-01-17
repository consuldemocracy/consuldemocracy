# module Mutations
#   class SubmitProposal < BaseMutation
#     argument :title, String, required: true, validates: { allow_blank: false }
#     argument :description, String, required: true, validates: { allow_blank: false }
#     argument :tag_list, String, required: false
#     argument :terms_of_service, Boolean, required: true

#     # TODO: Add file uploads

#     type Types::ProposalType

#     def resolve(title:, description:, summary:, terms_of_service:, geozone_id: nil, video_url: nil, tag_list: nil)
#       begin
#         Proposal.create!({
#           video_url: video_url,
#           geozone_id: geozone_id,
#           # TODO: Add map feature
#           # map_location_attributes: {
#           #   latitude: "",
#           #   longitude: "",
#           #   zoom:""
#           # },
#           translations_attributes: {
#             '0': {
#               locale: context[:current_resource].locale,
#               title: title,
#               description: description,
#               summary: summary
#             }
#           },
#           author: context[:current_resource],
#           tag_list: tag_list,
#           terms_of_service: terms_of_service
#         })
#       rescue ActiveRecord::RecordInvalid => e
#         raise GraphQL::ExecutionError, "#{e.message}"
#       end
#     end
#   end
# end
