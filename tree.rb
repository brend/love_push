class Tree
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
  
  def prune_dead_ends
    child_count_before = @children.count
    
    @children.reject! {|token, child| child != nil && child.dead_end?}
    
    child_count_after = @children.count
    change = child_count_before != child_count_after
    
    @children.each do |token, child|
      change |= child.prune_dead_ends unless child.nil?
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