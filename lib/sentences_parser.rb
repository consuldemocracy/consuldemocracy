module SentencesParser

  def detect_split_position(text)
    minimum_valid_index = text.size - MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST
    valid_point = text[minimum_valid_index..text.size].index('.')
    valid_whitespace = text[minimum_valid_index..text.size].index(' ')

    split_position = get_split_position(valid_point, valid_whitespace, minimum_valid_index)
  end

  def get_split_position(valid_point, valid_whitespace, minimum_valid_index)
    split_position = minimum_valid_index
    if valid_point.present? || valid_whitespace.present?
      valid_position = valid_point.present? ? valid_point : valid_whitespace
      split_position = split_position + valid_position
    end
    split_position
  end

  def characters_count(texts)
    texts.map(&:size).reduce(:+)
  end

end
