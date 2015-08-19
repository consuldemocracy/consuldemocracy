SimpleCaptcha.always_pass = false

SimpleCaptcha.setup do |sc|
  # default: 100x28
  sc.image_size = '120x40'

  # default: 5
  sc.length = 6

  # default: simply_blue
  # possible values:
  # 'embosed_silver',
  # 'simply_red',
  # 'simply_green',
  # 'simply_blue',
  # 'distorted_black',
  # 'all_black',
  # 'charcoal_grey',
  # 'almost_invisible'
  # 'random'
  sc.image_style = 'simply_green'

  # default: low
  # possible values: 'low', 'medium', 'high', 'random'
  sc.distortion = 'random'

  # default: medium
  # possible values: 'none', 'low', 'medium', 'high'
  sc.implode = 'medium'

  # sc.image_style = 'mycaptha'
  # sc.add_image_style('mycaptha', [
  #     "-background '#F4F7F8'",
  #     "-fill '#86818B'",
  #     "-border 1",
  #     "-bordercolor '#E0E2E3'"])
end
