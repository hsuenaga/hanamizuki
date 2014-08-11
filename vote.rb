class Vote
  attr_reader :fname, :haiku, :rank, :rank_str, :from
  def initialize(fname, haiku, rank, from)
    @fname = fname
    @haiku = haiku
    @rank_str = rank
    @rank = Rank::parse_rank(rank)
    @from = from
  end
end

class VoteList
  def initialize()
    @votes = Array.new()
  end

  def vote(fname, haikus, authors, composition, rank, from_name)
    haiku = haikus.bycomposition(composition)
    raise HaikuNotFound unless haiku

    to = haiku.author
    from = authors.byname(from_name)
    if !from
      print("Author not found: #{from_name}\n")
    end

    v = Vote.new(fname, haiku, rank, from)
    @votes << v

    haiku.vote(v.rank)
    from.vote(to, v.rank)
  end

  def each(&block)
    @votes.each do |vote|
      block.call(vote)
    end
  end

  def each_by_haiku(haiku, &block)
    array = Array.new()
    @votes.each do |vote|
      if vote.haiku == haiku
        array << vote
      end
    end
    array = array.sort_by() do |vote|
      vote.rank
    end
    array.reverse!()
    array.each do |vote|
      block.call(vote)
    end
  end
end


