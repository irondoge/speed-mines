#!/usr/bin/env ruby


require("./Map.rb")

def usage()
  print("Usage: sm WIDTHxHEIGHT MINE_PERCENTAGE\n")
  return (1)
end

def main(argv)
  if (argv.length != 2)
    return (usage())
  end
  map = MapUpdator.new(argv.first.split("x").map(&:to_i), argv.last[/\d+/].to_i)
  map.init_map(5, 5)
  return (0)
end

if (__FILE__ == $0)
  exit(main(ARGV))
end
