module ConsulAssemblies
  module Admin::ProposalsHelper

    def meetings_select_options(meetings)
      meetings.map do |meeting|
        [meeting.title, meeting.id]
      end
    end


  end
end
