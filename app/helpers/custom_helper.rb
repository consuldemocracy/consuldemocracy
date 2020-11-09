module CustomHelper
  def format_phone(phone)
    return "" if phone.blank?

    basic_phone = raw_phone(phone)

    "(#{basic_phone[0..2]}) #{basic_phone[3..5]} #{basic_phone[6..8]} #{basic_phone[9..11]}"
  end

  def raw_phone(phone)
    return "" if phone.blank?

    "+#{phone.delete(" ()-").delete_prefix("+")}"
  end
end
