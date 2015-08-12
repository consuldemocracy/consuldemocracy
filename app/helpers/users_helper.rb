module UsersHelper
  def avatar_image(user, options = {})
    size          = options.fetch(:size)          { 100 }
    klass         = options.fetch(:class)         { '' }
    round_corners = options.fetch(:round_corners) { true }

    data_attributes = { height: size, width: size, "font-size" => (size * 0.6) }
    data_attributes.merge!(radius: (size * 0.13).round) if round_corners
    data_attributes.merge!(name: user.name)

    content_tag :img, nil, class: "avatar #{klass}", data: data_attributes
  end
end
