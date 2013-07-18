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
    # create and prune this offering's tree
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
    1.upto(500) do
      change = false
      @offerings.each do |o|
        change |= o.restrict
      end
      # return unless change
    end
  end
  
  def to_s
    name
  end
end

Tabemono = Variable.new('Tabemono')
Fashon = Variable.new('Fashon')
Interia = Variable.new('Interia')
Dougu = Variable.new('Dougu')
Shumi = Variable.new('Shumi')
Kawaii = Variable.new('Kawaii')
Kuuru = Variable.new('Kuuru')
Adaruto = Variable.new('Adaruto')
Goujasu = Variable.new('Goujasu')
Chinpin = Variable.new('Chinpin')

all_variables = [Tabemono,Fashon,Interia,Dougu,Shumi,Kawaii,Kuuru,Adaruto,Goujasu,Chinpin]

def girl(name)
  $g = Girl.new
  $g.name = name
  
  puts "You are pushing #{$g.name}."
end

$gift = nil

def offer(*gift)
  raise ArgumentError.new if gift.nil?
  raise Exception.new 'No es bueno zu diesem Zeitpunkt' unless $gift.nil?
  
  $gift = gift
  
  print "You give her #{gift.inspect}, "
end

def reaction(*tokens)
  raise ArgumentError.new if tokens.nil?
  raise Exception.new 'Maintenant ist das nicht erlaubt' if $gift.nil?
  
  $g.add_offering(Offering.new($gift, tokens))
  $gift = nil
  
  puts "she reacts #{tokens.inspect}."
end

# Do it!!
if ARGV.empty?
  puts "Usage: <script> <girl file>"
  exit
end

load ARGV.first

$g.analyze

puts "This is what I inferred about her preferences:"
all_variables.each {|var| puts "#{var}: #{var.possible_values.inspect}"}
