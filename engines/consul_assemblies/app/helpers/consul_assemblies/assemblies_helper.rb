module ConsulAssemblies
  module AssembliesHelper

    def namespaced_meeting_path(meeting, options={})
      @namespace_meeting_path ||= namespace
      case @namespace_meeting_path
      when "management"
        management_meeting_path(meeting, options)
      else
        meeting_path(meeting, options)
      end
    end
    
  end
end
