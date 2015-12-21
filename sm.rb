#!/usr/bin/env ruby


require("gosu")
require("#{File.dirname(__FILE__)}/Utils")
require("#{File.dirname(__FILE__)}/Constants")
require("#{File.dirname(__FILE__)}/Map")

class GameWindow < Gosu::Window
  attr_accessor(:img_list, :start, :coo, :map, :T1)

  def initialize(grid, map)
    super(WIDTH, HEIGHT, :fullscreen => FULLSCREEN)
    self.caption = TITLE
    @map = map
    @T1 = true
    @apm = 0
    @ape = 0
    @clock = 0
    grid_size = [ grid[0] * (BOX_SIZE + (2 * OFFSET)), \
                   grid[1] * (BOX_SIZE + (2 * OFFSET)) ]
    print("grid ", @grid_size, "\n")
    @start = [ ((WIDTH - grid_size.first) / 2) + OFFSET, \
              ((HEIGHT - grid_size.last) / 2) + OFFSET ]
    print("start ", start, "\n")
    @coo = Array.new(grid[1]) { Array.new(grid[0]) { Hash.new() } }
    @coo.each_index do |y|
      @coo[y].each_index do |x|
        @coo[y][x][:img] = IMG_TEMPLATES[:box]
        @coo[y][x][:coo] = Array.new()
        get_pos_from_coo(x, y).each_with_index do |n, id|
          @coo[y][x][:coo][id] = @start[id] + n
        end
        @coo[y][x][:coo] << 0
      end
    end
  end

  def needs_cursor?
    true
  end

  def get_pos_from_coo(x, y)
    [ (x * (BOX_SIZE + 2 * OFFSET)) + OFFSET, \
      (y * (BOX_SIZE + 2 * OFFSET)) + OFFSET ]
  end

  def get_hover(x, y)
    [ ((x - @start[0] - OFFSET) / (20 + (2 * OFFSET))).to_i(),
      ((y - @start[1] - OFFSET) / (20 + (2 * OFFSET))).to_i() ]
  end

  def update()
    @img_list = Array.new()
    @coo.each { |line| line.each { |img| @img_list += [ img ] } }
    @clock += (1.0/60)
  end

  def draw()
    IMG_TEMPLATES[:bg].draw(0, 0, 0)
    @img_list.each do |img|
      img[:img].draw(*img[:coo])
    end
    print("clock: ", @clock.to_i(), \
          ", apm: ", (@apm / (@clock / 60)).to_i(), \
          ", ape: ", (@ape / (@clock / 60)).to_i(), "\n")
  end

  def sync()
    if (!@T1)
      @coo.each_index do |y|
        @coo[y].each_index do |x|
          @coo[y][x][:img] = (@map.map[y][x][:open] \
                              ? IMG_TEMPLATES[@map.map[y][x][:proxy]] \
                              : IMG_TEMPLATES[(@map.map[y][x][:flag] \
                                               ? :flag : :box)])
        end
      end
    end
  end

  def disp_bombs()
    exit(1)
  end

  def button_down(key)
    case key
    when QUIT1, QUIT2
      close()
    when CLICK
      coo = get_hover(self.mouse_x, self.mouse_y)
      if (@T1)
        @map.init_map(*coo)
        @T1 = false
        print("T1 done\n")
      end
      if (@map.map[coo[1]] != nil \
          && @map.map[coo[1]][coo[0]] != nil \
          && !@map.map[coo[1]][coo[0]][:flag] && @map.open(*coo) == 1)
        print("BOOM\n")
        disp_bombs()
      end
      sync()
      @ape += 1
    when RCLICK
      @map.toggle_flag(*get_hover(self.mouse_x, self.mouse_y))
      sync()
      @ape += 1
    else
      print("NOPE\n")
    end
    @apm += 1
  end
end

class MapUpdator < Map
  def debug()
    @map.each do |gneuh|
      gneuh.each do |bru|
        print((bru[:open] \
               ? (settrue(bru[:proxy]) ? bru[:proxy] : " ") \
               : (bru[:bomb] ? "B" : "K")), " ")
      end
      print("\n")
    end
    print("\n")
  end

  def flag_somme(x, y)
    ct = 0
    ((y - 1)..(y + 1)).each do |h|
      ((x - 1)..(x + 1)).each do |w|
        if (!(x == w && y == h) && @map[h] != nil && @map[h][w] != nil)
          ct += @map[h][w][:flag].to_i()
        end
      end
    end
    return (ct)
  end

  def toggle_flag(x, y)
    if (@map[y] != nil && @map[y][x] != nil && !@map[y][x][:open])
      @map[y][x][:flag] = !@map[y][x][:flag]
    end
  end

  def open(x, y)
    if (@map[y][x][:bomb])
      return (1)
    end
    if (@map[y][x][:open] && flag_somme(x, y) == @map[y][x][:proxy])
      ((y - 1)..(y + 1)).each do |h|
        ((x - 1)..(x + 1)).each do |w|
          if (h > -1 && w > -1 && @map[h][w][:bomb] && !@map[h][w][:flag])
            return(1)
          end
          if (h > -1 && w > -1 && @map[h] != nil && @map[h][w] != nil \
                             && !@map[h][w][:open] && !@map[h][w][:bomb] \
                             && !@map[h][w][:flag])
            if (@map[h][w][:proxy] > 0)
              @map[h][w][:open] = true
            elsif (@map[h][w][:proxy] == 0)
              open(w, h)
            end
          end
        end
      end
    elsif (!@map[y][x][:open])
      @map[y][x][:open] = true
      ((y - 1)..(y + 1)).each do |h|
        ((x - 1)..(x + 1)).each do |w|
          if (h > -1 && w > -1 && @map[h] != nil && @map[h][w] != nil \
                             && !@map[h][w][:open] && !@map[h][w][:bomb])
            if (@map[h][w][:proxy] > 0 && @map[y][x][:proxy] == 0)
              @map[h][w][:open] = true
            elsif (@map[h][w][:proxy] == 0)
              open(w, h)
            end
          end
        end
      end
    end
    return (0)
  end
end

def usage()
  print("Usage: sm WIDTHxHEIGHT MINE_PERCENTAGE\n")
  return (1)
end

def main(argv)
  if (argv.length != 2)
    return (usage())
  end
  grid = argv.first.split("x").map(&:to_i)
  map = MapUpdator.new(grid, argv.last[/\d+/].to_i)
  win = GameWindow.new(grid, map)
  win.show()
  return (0)
end

if (__FILE__ == $0)
  exit(main(ARGV))
end
