#!/usr/bin/env ruby


class Map
  attr_accessor(:size, :percent, :bombs, :map, :mined)

  def initialize(size, percent)
    @size = size
    @size << (size.first * size.last)
    @percent = percent
    @bombs = (percent / 100.0 * @size.last).round()
    print(@size[0, 2], " and ", @bombs, "/", @size.last, "\n")
    @map = Array.new(@size[1]) { Array.new(@size[0]) { Hash.new() } }
  end

  def init_map(x, y)
    inc_start(x, y)
    ct = 0
    @bombs.times do
      x = rand(0..(@size[0] - 1))
      y = rand(0..(@size[1] - 1))
      while (@map[y][x].key?(:bomb) || @map[y][x].key?(:start)) do
        x = rand(0..(@size[0] - 1))
        y = rand(0..(@size[1] - 1))
      end
      inc_proxies(x, y)
      @map[y][x][:bomb] = true
      ct += 1
    end
    @map.each_index do |y|
      @map[y].each_index do |x|
        if (@map[y][x].empty?)
          @map[y][x][:bomb] = false
        end
        @map[y][x][:flag] = false
        @map[y][x][:open] = false
        if (!@map[y][x].key?(:proxy))
          @map[y][x][:proxy] = 0
        end
      end
    end
    # @map.each { |elem| print(elem, "\n") }
    # print(ct)
  end

  def inc_proxies(a, b)
    ((b - 1)..(b + 1)).each do |y|
      ((a - 1)..(a + 1)).each do |x|
        if (x > -1 && x < @size[0] && y > -1 && y < @size[1])
          if (!@map[y][x].key?(:proxy))
            @map[y][x][:proxy] = 1
          else
            @map[y][x][:proxy] += 1
          end
        end
      end
    end
  end

  def inc_start(a, b)
    @map[b][a][:start] = true
    ((b - 1)..(b + 1)).each do |y|
      ((a - 1)..(a + 1)).each do |x|
        if (x > -1 && x < @size[0] && y > -1 && y < @size[1])
          @map[y][x][:start] = true
        end
      end
    end
  end
end
