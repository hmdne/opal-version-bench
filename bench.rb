#!/usr/bin/env ruby
def bench(path, benchmark, executor = "node")
  file = "tmp/bench-#{rand}.js"
  system "benchmarks/#{benchmark} #{path} #{file}"
  t0 = Time.now
  system "#{executor} #{file}"
  Time.now - t0
end

if $0 == __FILE__
  puts bench(*ARGV)
end
