#!/bin/bash
OPAL="$1"
OUTPUT="$2"

if [ ! -d tmp/parslet ]; then
  git clone https://github.com/plurimath-js/parslet tmp/parslet
fi

cat >tmp/opal-parslet.rb <<EOF

require 'parslet'

class MiniP < Parslet::Parser
  # Single character rules
  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }
  rule(:comma)      { str(',') >> space? }

  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  # Things
  rule(:integer)    { match('[0-9]').repeat(1).as(:int) >> space? }
  rule(:identifier) { match['a-z'].repeat(1) }
  rule(:operator)   { match('[+]') >> space? }

  # Grammar parts
  rule(:sum)        {
    integer.as(:left) >> operator.as(:op) >> expression.as(:right) }
  rule(:arglist)    { expression >> (comma >> expression).repeat }
  rule(:funcall)    {
    identifier.as(:funcall) >> lparen >> arglist.as(:arglist) >> rparen }

  rule(:expression) { funcall | sum | integer }
  root :expression
end

IntLit = Struct.new(:int) do
  def eval; int.to_i; end
end
Addition = Struct.new(:left, :right) do
  def eval; left.eval + right.eval; end
end
FunCall = Struct.new(:name, :args) do
  def eval; args.map { |s| s.eval }; end # printing disabled
end

class MiniT < Parslet::Transform
  rule(:int => simple(:int))        { IntLit.new(int) }
  rule(
    :left => simple(:left),
    :right => simple(:right),
    :op => '+')                     { Addition.new(left, right) }
  rule(
    :funcall => 'puts',
    :arglist => subtree(:arglist))  { FunCall.new('puts', arglist) }
end

parser = MiniP.new
transf = MiniT.new

ast = transf.apply(
  parser.parse(
    'puts(' + ('1,2,3, 4+5, ')*6000 + '123)'))

ast.eval

EOF

./run-opal.sh $OPAL -I`pwd`/tmp/parslet/lib -c `pwd`/tmp/opal-parslet.rb > $OUTPUT

