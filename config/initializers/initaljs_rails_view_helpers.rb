require 'json'

module InitialjsRails
  module ViewHelpers
    def avatar_image(avatarable, options = {})
      size          = options.fetch(:size)             { 100 }
      klass         = options.fetch(:class)            { '' }
      round_corners = options.fetch(:round_corners)    { true }
      seed          = options.fetch(:seed)             { 0 }
      char_count    = options.fetch(:count)            { 1 }
      txt_color     = options.fetch(:color)            { '#ffffff' }
      bg_color      = options.fetch(:background_color) { nil }
      initial_src   = options.fetch(:src)              { '/assets/initialjs-blank.png' }
      radius        = (size * 0.13).round if round_corners
      font_size     = (size * 0.6).round

      data_attributes = {
        'char-count' => char_count,
        color: bg_color,
        'font-size' => font_size,
        height: size,
        name: get_name_with_count(avatarable, char_count),
        radius: radius,
        seed: seed,
        'text-color' => txt_color,
        width: size
      }.reject { |_, v| v.blank? }

      tag(:img, { alt: get_name(avatarable), class: "initialjs-avatar #{klass}".strip, data: data_attributes, src: initial_src }, true, false)
    end

    def get_name_with_count(avatarable, count)
      name = get_name(avatarable)
      if count == 2
        "#{name.partition(" ").first[0]}#{name.partition(" ").last[0]}"
      else
        name
      end
    end

    def get_name(avatarable)
      if avatarable.is_a?(String)
        avatarable
      elsif avatarable.respond_to?(:name)
        avatarable.name
      else
        raise ArgumentError, '#avatar_image argument must be a String or respond to :name'
      end
    end
  end
end
