module RemoteTranslations::Microsoft::SentencesParser
  def detect_split_position(text)
    limit = RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST
    minimum_valid_index = text.size - limit
    valid_point = text[minimum_valid_index..text.size].index(".")
    valid_whitespace = text[minimum_valid_index..text.size].index(" ")

    get_split_position(valid_point, valid_whitespace, minimum_valid_index)
  end

  def get_split_position(valid_point, valid_whitespace, minimum_valid_index)
    split_position = minimum_valid_index
    if valid_point.present? || valid_whitespace.present?
      valid_position = valid_point.presence || valid_whitespace
      split_position = split_position + valid_position
    end
    split_position
  end

  def characters_count(texts)
    texts.sum(&:size)
  end
end
