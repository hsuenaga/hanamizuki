class Word
  attr_reader :id, :theme, :string

  def initialize(theme, id, string)
    @id = id
    @theme = theme
    @string = string
  end
end

class Theme
  attr_reader :fname, :words, :winner, :winner_point, :id

  def initialize(fname, id, date)
    @fname = fname
    @id = id
    @words = Array.new()
    @winner = nil
    @winner_point = 0
    @date = date
  end

  def add(string, id)
    word = Word.new(self, id, string)
    @words << word
  end

  def win(name, point)
    @winner = name
    @winner_point = point
  end

  def each(&block)
    @words.each do |word|
      block.call(word)
    end
  end

  def str_array()
    array = Array.new()
    @words.each do |word|
      array << word.string
    end
    array
  end
end

class ThemeList
  def initialize()
    @themes = Hash.new()
    @theme_id = 0
    @word_id = 0
  end

  def fname2date(string)
    tok = string.split("-")
    year = tok[0]
    month = tok[1]
    @date = year.to_i() * 10000 + month.to_i() * 100
  end

  def append(fname, word)
    theme = nil
    date = fname2date(fname)
    if @themes.has_key?(date)
      theme = @themes[date]
      if word then
        theme.add(word, @word_id)
        @word_id += 1
      end
    else
      theme = Theme.new(fname, @theme_id, date)
      @theme_id += 1
      if word then
        theme.add(word, @word_id)
        @word_id += 1
      end
      @themes[date] = theme
    end
    theme
  end

  def byfname(fname)
    date = fname2date(fname)
    if !@themes.has_key?(date)
      raise RuntimeError
    end
    @themes[date]
  end

  def each(&block)
    theme_list = @themes.keys().sort()

    theme_list.each do |date|
      block.call(@themes[date])
    end
  end

  def each_word(&block)
    theme_list = @themes.keys().sort()

    theme_list.each do |date|
      @themes[date].each do |word|
        block.call(word)
      end
    end
  end

  def getword(string)
    each_word do |word|
      return word if word.string == string
    end
    return nil
  end
end
