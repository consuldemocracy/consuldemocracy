module DownloadSettings
  module ProposalCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      ["author_name", "author_email"]
    end

    def get_downloadables_names(config)
      DownloadSetting.where(name_model: "Proposal",
                            downloadable: true,
                            config: config).pluck(:name_field)
    end

    def to_csv(proposals, admin_attr, options = {})

      attributes = admin_attr.nil? ? [] : admin_attr

      CSV.generate(options) do |csv|
        csv << attributes
        proposals.each do |proposal|
          csv << attributes.map {|attr| proposal.send(attr)}
        end
      end
    end

  end
end
