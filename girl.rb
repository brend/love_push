require 'variable'

class Girl
  attr_accessor :name
  
  def initialize
    @offerings = []
    @name = nil
  end
  
  def add_offering(o)
    @offerings << o
  end
  
  def analyze
    while true
      change = false
      @offerings.each do |o|
        change |= o.restrict
      end
      return unless change
    end
  end
  
  def to_s
    name
  end
end