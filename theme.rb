class Theme
  attr_reader :fname, :words, :winner, :winner_point

  def initialize(fname)
    @fname = fname
    @words = Array.new
    @winner = nil
    @winner_point = 0
  end

  def add(string)
    @words << string
  end

  def win(name, point)
    @winner = name
    @winner_point = point
  end
end

class ThemeList
  def initialize()
    @themes = Hash.new()
  end

  def append(fname, word)
    theme = nil
    if @themes.has_key?(fname)
      theme = @themes[fname]
      theme.add(word) if word
    else
      theme = Theme.new(fname)
      theme.add(word) if word
      @themes[fname] = theme
    end
    theme
  end

  def byfname(fname)
    return nil if @themes.has_key?(fname)
    @themes[fname]
  end

  def each(&block)
    keys = @themes.keys().sort()

    keys.each do |key|
      block.call(@themes[key])
    end
  end
end


