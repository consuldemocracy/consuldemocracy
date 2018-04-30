require 'rails_helper'

describe Document do

  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

end

# == Schema Information
#
# Table name: documents
#
#  id                      :integer          not null, primary key
#  title                   :string
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  user_id                 :integer
#  documentable_id         :integer
#  documentable_type       :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
