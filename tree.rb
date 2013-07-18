class Node
  attr_reader :label, :children
  
  def initialize(var)
    @label = var
    @children = {}
  end
  
  def add_child(token, tree)
    @children[token] = tree
  end
  
  def dead_end?
    @children.empty?
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
      change |= prune_dead_ends
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
      change |= child.prune_impossible_values
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
      remaining_tokens.delete_at(remaining_tokens.index(token))
      change |= child.prune_impossible_paths(remaining_tokens)
    end
    
    change
  end
  
  def prune_dead_ends
    child_count_before = @children.count
    
    @children.reject! {|token, child| child.dead_end?}
    
    child_count_after = @children.count
    change = child_count_before != child_count_after
    
    @children.each do |token, child|
      change |= child.prune_dead_ends
    end
    
    change
  end
  
  def possible_values
    nodes = [self]
    result = {}
    
    until nodes.empty?
      nodes.pop.add_possible_values(nodes, result)      
    end
    
    result
  end
  
  def add_possible_values(nodes, result)
    result[label] = Set.new unless result.include?(label)
    result[label] += children.keys
    nodes.insert(0, *children.values)
  end
end

class Leaf
  def dead_end?
    false
  end
  
  def prune_impossible_values
  end
  
  def prune_impossible_paths(tokens)
    raise Exception.new("Leaf has been reached, tokens are not empty: #{tokens}") unless tokens.empty?
  end
  
  def prune_dead_ends
  end
  
  def add_possible_values(nodes, result)
  end
end
