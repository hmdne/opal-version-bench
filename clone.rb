#!/usr/bin/env ruby

def clone(to, checkout = 'master', from = "https://github.com/opal/opal")
  system "git clone #{from} #{to}"
  system "pushd #{to}; git checkout #{checkout}"
end

if $0 == __FILE__
  clone(*ARGV)
end
