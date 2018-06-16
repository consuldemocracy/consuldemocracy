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
    Setting.create(key: 'documents_proposal_max_file_size', value: '3')
    Setting.create(key: 'documents_proposal_max_documents_allowed', value: '3')
    Setting.create(key: 'documents_proposal_accepted_content_types', value: 'application/pdf')
    Setting.create(key: 'documents_budget_investment_max_file_size', value: '3')
    Setting.create(key: 'documents_budget_investment_max_documents_allowed', value: '3')
    Setting.create(key: 'documents_budget_investment_accepted_content_types', value: 'application/pdf')
    Setting.create(key: 'documents_budget_investment_milestone_max_file_size', value: '3')
    Setting.create(key: 'documents_budget_investment_milestone_max_documents_allowed', value: '3')
    Setting.create(key: 'documents_budget_investment_milestone_accepted_content_types', value: 'application/pdf')
    Setting.create(key: 'documents_legislation_process_max_file_size', value: '3')
    Setting.create(key: 'documents_legislation_process_max_documents_allowed', value: '3')
    Setting.create(key: 'documents_legislation_process_accepted_content_types', value: 'application/pdf')
    Setting.create(key: 'documents_legislation_proposal_max_file_size', value: '3')
    Setting.create(key: 'documents_legislation_proposal_max_documents_allowed', value: '3')
    Setting.create(key: 'documents_legislation_proposal_accepted_content_types', value: 'application/pdf')
    Setting.create(key: 'documents_poll_question_answer_max_file_size', value: '3')
    Setting.create(key: 'documents_poll_question_answer_max_documents_allowed', value: '3')
    Setting.create(key: 'documents_poll_question_answer_accepted_content_types', value: 'application/pdf')

  end
end
