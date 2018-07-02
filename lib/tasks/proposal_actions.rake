namespace :proposal_actions do
  desc 'Move link attribute to links collection'
  task migrate_links: :environment do
    ProposalDashboardAction.where.not(link: nil).each do |action|
      next if action.link.blank?

      Link.create!(
        label: action.title,
        url: action.link,
        open_in_new_tab: true,
        linkable: action
      )
    end
  end 
end
