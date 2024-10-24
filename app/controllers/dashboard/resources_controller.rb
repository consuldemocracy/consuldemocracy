class Dashboard::ResourcesController < Dashboard::BaseController
  skip_authorization_check

  def index
    @resources = Dashboard::Action
                 .active
                 .resources
                 .where("required_supports > 0")
                 .order(required_supports: :asc)

    render json: @resources.map { |resource|
      {
        id: resource.id,
        title: resource.title,
        required_supports: resource.required_supports
      }
    }
  end
end
