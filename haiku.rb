class Haiku
  attr_reader :fname, :composition, :author, :point, :sort_val
  attr_accessor :id

  def initialize(fname, composition, author)
    @fname = fname
    @composition = composition
    @author = author
    @id = 0
    @point = 0
    @sort_val = 0
  end

  def vote(point)
    @point += point
    @sort_val += Rank::sort_val(point)
  end
end

class HaikuList
  def initialize()
    @db = Hash.new()
    @id_list = Array.new()
    @id = 0
  end

  def append(fname, composition, author)
    haiku = Haiku.new(fname, composition, author)
    raise DuplicatedHaiku if @db.has_key?(composition)

    idx = @id
    @id += 1

    haiku.id = idx
    @db[composition] = haiku
    @id_list[idx] = haiku
    haiku
  end

  def bycomposition(composition)
    return nil unless @db.has_key?(composition)

    @db[composition]
  end

  def byid(id)
    @id_list[id]
  end

  def each(&block)
    @id_list.each do |haiku|
      block.call(haiku)
    end
  end

  def sort_by_point(&block)
    array = @id_list.sort_by do |haiku|
      haiku.sort_val
    end
    array.reverse!

    array.each do |haiku|
      block.call(haiku)
    end
  end

  def count_fname(fname)
    count = 0
    @id_list.each do |haiku|
      if haiku.fname == fname then
        count += 1
      end
    end
    count
  end

  def each_by_author(author, &block)
    array = Array.new()
    @id_list.each do |haiku|
      next if haiku.author != author
      array << haiku
    end
    array = array.sort_by do |haiku|
      haiku.point
    end
    array.reverse!
    array.each do |haiku|
      block.call(haiku)
    end
  end
end
