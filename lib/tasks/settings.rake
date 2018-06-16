namespace :settings do

  desc "Changes Setting key per_page_code for per_page_code_head"
  task per_page_code_migration: :environment do
    per_page_code_setting = Setting.where(key: 'per_page_code').first

    Setting['per_page_code_head'] = per_page_code_setting&.value.to_s if Setting.where(key: 'per_page_code_head').first.blank?
    per_page_code_setting.destroy if per_page_code_setting.present?
  end

  desc "Create new Attached Documents feature setting"
  task create_attached_documents_setting: :environment do
    Setting['feature.allow_attached_documents'] = true
  end

  desc "Initialize max size, number, allowed and accepted content types"
  task initialize_attached_documents_setting: :environment do
    Setting['documents.proposal.max_file_size'] = '3'
    Setting['documents.proposal.max_documents_allowed'] = '3'
    Setting['documents.proposal.accepted_content_types'] = "application/pdf"
    Setting['documents.budget_investment.max_file_size'] = '3'
    Setting['documents.budget_investment.max_documents_allowed'] = '3'
    Setting['documents.budget_investment.accepted_content_types'] = "application/pdf"
    Setting['documents.budget_investment_milestone.max_file_size'] = '3'
    Setting['documents.budget_investment_milestone.max_documents_allowed'] = '3'
    Setting['documents.budget_investment_milestone.accepted_content_types'] = "application/pdf"
    Setting['documents.legislation_process.max_file_size'] = '3'
    Setting['documents.legislation_process.max_documents_allowed'] = '3'
    Setting['documents.legislation_process.accepted_content_types'] = "application/pdf"
    Setting['documents.legislation_proposal.max_file_size'] = '3'
    Setting['documents.legislation_proposal.max_documents_allowed'] = '3'
    Setting['documents.legislation_proposal.accepted_content_types'] = "application/pdf"
    Setting['documents.poll_question_answer.max_file_size'] = '3'
    Setting['documents.poll_question_answer.max_documents_allowed'] = '3'
    Setting['documents.poll_question_answer.accepted_content_types'] = "application/pdf"
  end
end
