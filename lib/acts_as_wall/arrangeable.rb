module Arrangeable
  def arrange
    return self if empty?
    Kernel.const_get("#{first.class}Group").arrange self
  end
end

Array.send :include, Arrangeable
ActiveRecord::Relation.send :include, Arrangeable