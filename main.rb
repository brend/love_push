require 'set'

# Constants
O = :O
X = :X
E = :E

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
    # create this offering's tree
    t = span_tree
    t.prune(reaction)
    # restrict possible values according to this offering's tree
    t.possible_values.each do |var, possible_tokens|
      var.possible_values = possible_tokens.to_a
    end
  end
end

class Variable
  attr_accessor :name, :possible_values
  
  def initialize(name)
    @name = name
    @possible_values = [O, X, E]
  end
  
  S = Variable.new('s')
  A = Variable.new('a')
  C = Variable.new('c')
  
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

class Tree
  attr_reader :label, :children
  
  def initialize(var)
    @label = var
    @children = {}
  end
  
  def add_child(token, tree)
    @children[token] = tree
  end
  
  def to_s
    "(#{label}, #{children.inspect})"
  end
    
  def inspect
    to_s
  end
    
  def prune(available_tokens)
    while true      
      change = false
      change |= prune_impossible_values
      change |= prune_impossible_paths(available_tokens)
      return unless change
    end
  end
  
  def prune_impossible_values
    child_count_before = @children.count
    
    # remove impossible transitions
    @children.reject! {|token, child| not label.possible?(token)}
    
    child_count_after = @children.count
    change = child_count_before != child_count_after
    
    # prune children
    @children.each do |token, child| 
      change |= child.prune_impossible_values unless child.nil?
    end
    
    change
  end
  
  def prune_impossible_paths(available_tokens)
    child_count_before = @children.count
    
    @children.reject! {|token, child| not available_tokens.include?(token)}
    
    child_count_after = @children.count
    change = child_count_before != child_count_after
    
    @children.each do |token, child|
      remaining_tokens = available_tokens.clone
      remaining_tokens.delete_at(remaining_tokens.index(token) || remaining_tokens.length)
      change |= child.prune_impossible_paths(remaining_tokens) unless child.nil?
    end
    
    change
  end
  
  def possible_values
    nodes = [self]
    result = {}
    
    until nodes.empty?
      n = nodes.pop
      
      next if n.nil?
      
      l = n.label
      result[l] = Set.new unless result.include?(l)
      result[l] += n.children.keys
      nodes += n.children.values
    end
    
    result
  end
end

S = Variable.new('s')
A = Variable.new('a')
C = Variable.new('c')

# Debug
puts "Vorher. p(a) = #{A.possible_values}, p(c) = #{C.possible_values}"
r = Offering.new([A, C], [X, E])
r.restrict
puts "Nachher. p(a) = #{A.possible_values}, p(c) = #{C.possible_values}"
