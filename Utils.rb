#!/usr/bin/env ruby


class FalseClass
  def to_i()
    0
  end
end

class TrueClass
  def to_i()
    1
  end
end

def settrue(x)
  x == 0 ? false : true
end
