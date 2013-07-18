require 'tree'

class Offering
  attr_reader :gift, :reaction
  
  def initialize(gift, reaction)
    @gift = gift
    @reaction = reaction
  end
  
  def to_s
    "#{gift.inspect} -> #{reaction.inspect}"
  end
  
  def inspect
    to_s
  end
  
  def span_tree_rec(variables)
    return nil if variables.empty?
    
    root_variable = variables.pop
    
    t = Tree.new(root_variable)
    
    [O, X, E].each do |token|    
      # Note: Don't move ct out of the block, because each subtree must be unique
      ct = span_tree_rec(variables.clone)
      t.add_child(token, ct)
    end
    
    t
  end
  
  def span_tree
    span_tree_rec(gift.clone)
  end
  
  def restrict
    # create and prune this offering's tree
    t = span_tree
        
    t.prune(reaction)
    
    # restrict possible values according to this offering's tree
    t.possible_values.each do |var, possible_tokens|
      var.possible_values = possible_tokens.to_a    
    end
  end
end
