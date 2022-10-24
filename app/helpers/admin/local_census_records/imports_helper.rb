module Admin::LocalCensusRecords::ImportsHelper
  def errors_for(resource, field)
    if resource.errors.include? field
      tag.div class: "error" do
        resource.errors[field].join(", ")
      end
    end
  end
end
