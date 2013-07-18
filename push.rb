require 'set'
require 'variable'

# Constants
O = :O
X = :X
E = :E

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

require 'offering'
require 'girl'

# define DSL interface
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
