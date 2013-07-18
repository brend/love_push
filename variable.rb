class Variable
  attr_accessor :name, :possible_values
  
  def initialize(name)
    @name = name
    @possible_values = [O, X, E]
  end
  
  def to_s
    name
  end
  
  def inspect
    to_s
  end
  
  def possible?(token)
    possible_values.include?(token)
  end
end