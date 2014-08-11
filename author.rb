#
# Author Information Store
#
class Author
  attr_reader :id, :name, :point, :total_vote, :sort_val
  attr_accessor :profile
  def initialize(id, name)
    @id = id
    @name = name
    @point = 0
    @total_vote = 0
    @vote_to = Hash.new()
    @profile = ""
    @sort_val = 0
  end

  def vote(to, point)
    @total_vote += point
    to.add_point(point)
    if !@vote_to.has_key?(to)
      @vote_to[to] = 0
    end
    @vote_to[to] += point
  end

  def add_point(point)
    @point += point
    @sort_val += Rank::sort_val(point)
  end

  def vote_point(to)
    return 0 unless @vote_to.has_key?(to)
    return @vote_to[to]
  end

  def vote_ratio(to)
    return "-" unless @total_vote
    return "-" unless @vote_to.has_key?(to)

    ratio = 100 * @vote_to[to] / @total_vote
    "#{ratio.to_i()}%"
  end
end

class AuthorList
  NameReplace = {
    "ビト" => "柏尾川",
    "タナカ" => "三指奏"
  }

  def initialize()
    @names = Hash.new()
    @ids = Array.new()
    @id = 0
  end

  def append(name)
    if NameReplace.has_key?(name)
      name = NameReplace[name]
    end

    if @names.has_key?(name)
      return @names[name]
    end


    idx = @id
    @id += 1
    author = Author.new(idx, name)

    @names[name] = author
    @ids.insert(idx, author)
    author
  end

  def profile(name, profile)
    author = append(name)
    author.profile = profile
  end

  def byname(name)
    if NameReplace.has_key?(name)
      name = NameReplace[name]
    end

    if @names.has_key?(name)
      return @names[name]
    end
    nil
  end

  def byid(id)
    @ids[id]
  end

  def each(&block)
    return unless block
    @ids.each do |author|
      block.call(author)
    end
  end

  def sort_by_point(&block)
    return unless block
    array = @ids.sort_by do |author|
      author.sort_val
    end
    array.reverse!

    array.each do |author|
      block.call(author)
    end
  end
end
