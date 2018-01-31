namespace :external_url do

  desc "Copy external url to description on Proposals"
  task proposals: :environment do

    Proposal.where('external_url is not null').all.each do |proposal|
      proposal.description += "\r\n\r\n<p><strong>Additional documentation: </strong><a>#{proposal.external_url}</a></p>".html_safe
      proposal.external_url = nil
      proposal.save!
    end

  end

  desc "Copy external url to description on Budget::Investments"
  task investments: :environment do

    Budget::Investment.where('external_url is not null').all.each do |investment|
      investment.description += "\r\n\r\n<p><strong>Additional documentation: </strong><a>#{investment.external_url}</a></p>".html_safe
      investment.external_url = nil
      investment.save!
    end

  end

end
