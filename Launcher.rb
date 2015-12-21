#!/usr/bin/env ruby

class   LaunchWindow < Gosu::Window
  attr_accessor(:width, :height, :offset)

  def   initialize()
    super(WIDTH_LAUNCH, HEIGHT_LAUNCH, :fullscreen => FULLSCREEN_LAUNCH)
    self.caption = TITLE_LAUNCH
    @title_launch = IMG_TEMPLATES[:title_launch]
    @font = Gosu::Font.new(25)
  end
  
  def update
  end

  def draw
    @title_launch.draw(0,0,0)
    @font.draw("Score:", 100, 10, 0, 1.0, 1.0, 0xff_ffffff)
  end
end

window = LaunchWindow.new
window.show
