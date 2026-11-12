module DocumentParser
  def document_number_variants(document_type, document_number)
    normalized_number = document_number.to_s.gsub(/[^0-9A-Za-z]/i, "")

    return [] if normalized_number.blank?
    return [normalized_number] unless dni?(document_type)

    number_part, letter = split_letter_from(normalized_number)
    number_variants = number_variants_with_leading_zeros_from(number_part)

    if letter
      number_variants.flat_map do |variant|
        [variant, variant + letter.downcase, variant + letter.upcase]
      end
    else
      number_variants
    end
  end

  def split_letter_from(document_number)
    if document_number.last.match?(/[a-z]/i)
      [document_number[0..-2], document_number.last]
    else
      [document_number, nil]
    end
  end

  def number_variants_with_leading_zeros_from(document_number, digits = 8)
    number_without_leading_zeros = document_number.last(digits).gsub(/^0+/, "")

    return [] if number_without_leading_zeros.blank?
    return [number_without_leading_zeros] if number_without_leading_zeros.size >= digits

    (0..(digits - number_without_leading_zeros.size)).map do |number_of_leading_zeros|
      "0" * number_of_leading_zeros + number_without_leading_zeros
    end
  end

  def dni?(document_type)
    document_type.to_s == "1"
  end
end
