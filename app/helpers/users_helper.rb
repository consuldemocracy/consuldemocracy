module UsersHelper
  def avatar_image(user, options = {})
    style         = options.fetch(:style)         { :small }
    klass         = options.fetch(:class)         { '' }
    round_corners = options.fetch(:round_corners) { true }

    data_attributes = case style
      when :profile
        { height: 100, width: 100 }
      when :small
        { height: 32, width: 32, "font-size" => 20 }
      else
        {}
      end

    if round_corners
      radius = (data_attributes[:height].to_i * 0.13).round
      data_attributes.merge!(radius: radius)
    end
    data_attributes.merge!(name: user.name)

    content_tag :img, nil, class: "avatar #{klass}", data: data_attributes
  end
end
