class Object

  def blank?
    false
  end

  def present?
    true
  end

end

class String

  def blank?
    empty?
  end

  def present?
    !blank?
  end

end

class NilClass

  def blank?
    true
  end

  def present?
    false
  end

end
