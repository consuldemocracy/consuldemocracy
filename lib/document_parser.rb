module DocumentParser

  def get_document_number_variants(document_type, document_number)
    # Delete all non-alphanumerics
    document_number = document_number.to_s.gsub(/[^0-9A-Za-z]/i, '')
    variants = []

    if dni?(document_type)
      document_number, letter = split_letter_from(document_number)
      number_variants = get_number_variants_with_leading_zeroes_from(document_number)
      letter_variants = get_letter_variants(number_variants, letter)

      variants += number_variants
      variants += letter_variants
    else # if not a DNI, just use the document_number, with no variants
      variants << document_number
    end

    variants
  end

  def split_letter_from(document_number)
    letter = document_number.last
    if letter[/[A-Za-z]/] == letter
      document_number = document_number[0..-2]
    else
      letter = nil
    end
    [document_number, letter]
  end

  # if the number has less digits than it should, pad with zeros to the left and add each variant to the list
  # For example, if the initial document_number is 1234, and digits=8, the result is
  # ['1234', '01234', '001234', '0001234']
  def get_number_variants_with_leading_zeroes_from(document_number, digits = 8)
    document_number = document_number.to_s.last(digits) # Keep only the last x digits
    document_number = document_number.gsub(/^0+/, '')   # Removes leading zeros

    variants = []
    variants << document_number if document_number.present?
    while document_number.size < digits
      document_number = "0#{document_number}"
      variants << document_number
    end
    variants
  end

  # Generates uppercase and lowercase variants of a series of numbers, if the letter is present
  # If number_variants == ['1234', '01234'] & letter == 'A', the result is
  # ['1234a', '1234A', '01234a', '01234A']
  def get_letter_variants(number_variants, letter)
    variants = []
    if letter.present?
      number_variants.each do |number|
        variants << number + letter.downcase << number + letter.upcase
      end
    end
    variants
  end
end
