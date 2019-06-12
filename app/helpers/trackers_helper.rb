module TrackersHelper

  def tracker_label(tracker)
    truncate([tracker.name, tracker.email, tracker.description].compact.join(" - "), length: 100)
  end

  def tracker_back_path(progressable)
    if progressable.class.to_s == "Legislation::Process"
      admin_legislation_process_milestones_path(progressable)
    else
      polymorphic_path([tracker_namespace, *resource_hierarchy_for(progressable)])
    end
  end

  private

    def tracker_namespace
      current_user.administrator? ? :admin : :tracking
    end

end
