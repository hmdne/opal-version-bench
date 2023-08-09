#!/bin/bash
OPAL="$1"
OUTPUT="$2"

if [ ! -f tmp/opal-sample.rb ]; then
  ./clone.rb tmp/opal-sample v1.1.0
fi

find tmp/opal-sample/lib/opal/nodes -name \*.rb -exec cat {} \; > tmp/opal-sample.rb

cat - tmp/opal-sample.rb >tmp/opal-compiler.rb <<EOF
require "opal-parser"

Opal.compile(DATA.read)

__END__
EOF

./run-opal.sh $OPAL -c `pwd`/tmp/opal-compiler.rb > $OUTPUT

