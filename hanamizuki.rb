#!/usr/bin/env ruby
require 'optparse'
require 'html_writer'

#
# Name Configuration
#
MyURL = "http://www3037uo.sakura.ne.jp"
Title = "花水木7月"
SiteName = "花水木"
SiteURL = "http://haiku-hanamizuki.seesaa.net"
DataDir = "./data"

NameReplace = {
    "ビト" => "柏尾川",
    "タナカ" => "三指奏"
}

RankDef = {
  "天" => 4,
  "地" => 3,
  "人" => 2,
  "佳作" => 1
}

#
# Rank Configuration
#
class Rank
  def self.parse_rank(string)
    raise InvalidRank unless RankDef.has_key?(string)
    RankDef[string]
  end

  def self.sort_val(point)
    val = point * 1000000
    case point
    when 4
      val += 10000
    when 3
      val += 100
    when 2
      val += 1
    end

    val
  end
end

#
# Exception
#
class DuplicatedHaiku < Exception; end
class HaikuNotFound < Exception; end
class ParseError < Exception; end
class InvalidRank < Exception; end
UserExceptions = [DuplicatedHaiku, HaikuNotFound, ParseError, InvalidRank]

def exception_handler(exception, file, line, string)
  case exception
  when DuplicatedHaiku
    print("俳句が重複")
  when HaikuNotFound
    print("俳句が見つからない")
  when InvalidRank
    print("評価が不明")
  when ParseError
    print("文法エラー")
  else
    print("未定義エラー")
  end
  print(": ファイル #{file}.txt: #{line} 行目\n")
  print("#{string}\n")
  exit
end

#
# File List for Analysis
#
class FileList
  def initialize(dir)
    @files = Array.new()

    Dir.glob("#{DataDir}/*.txt") do |fname|
      @files << File.open(fname)
    end
  end

  def each(&block)
    return unless block
    @files.each do |f|
      block.call(f)
    end
  end
end

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

class Contest
  def initialize()
    @file = nil
    @themes = ThemeList.new()
    @authors = AuthorList.new()
    @haikus = HaikuList.new()
    @votes = VoteList.new()

    @cur_voter = nil
    @cur_file = nil
    @cur_line = 0
    @cur_content = nil
  end

  def parse_theme(string)
    string.gsub!("「", "")
    string.gsub!("」", "")
    @themes.append(@cur_file, string)
  end

  def parse_author(string)
    string.gsub!("選", "")
    return nil if string == "互"
    @authors.append(string)
  end

  def parse_haiku(composition, author)
    author = @authors.append(author)
    @haikus.append(@cur_file, composition, author)
  end

  def parse_vote(rank, composition, from_name)
    @votes.vote(@cur_file, @haikus, @authors, composition, rank, from_name)
  end

  def parse_winner(fname, winner, point)
    theme = @themes.append(fname, nil)
    theme.win(winner, point)
  end

  def parse_profile(author, profile)
    @authors.profile(author, profile)
  end

  def parse_line(line)
    @cur_content = line.dup()
    line.gsub!(/　+/, " ")
    line.gsub!(/ +/, " ")
    a = line.split(nil)
    begin
      case a[0]
      when "__勝者"
        raise ParseError unless a.count() == 4
        parse_winner(a[1], a[2], a[3])
        return
      when "__紹介"
        raise ParseError unless a.count() == 3
        parse_profile(a[1], a[2])
        return
      end

      case a.count()
      when 1
        if a[0].index("「")
          parse_theme(a[0])
        elsif a[0].index("選")
          parse_author(a[0])
          @cur_voter = a[0]
        else
          raise ParseError
        end
      when 2
        parse_haiku(a[0], a[1])
      when 3
        parse_vote(a[0], a[1], @cur_voter)
      else
        raise ParseError
      end
    rescue *UserExceptions => e
      exception_handler(e, @cur_file, @cur_line, @cur_content)
      raise RuntimeError
    end
  end

  def load(file)
    @cur_line = 0
    @cur_file = File::basename(file.path())
    @cur_file.sub!(".txt", "")
    file.each do |line|
      @cur_line += 1
      line.chop!()
      next if line == ""
      parse_line(line)
    end
  end

  def html(output)
    writer = HtmlWriter.new(@themes, @authors, @haikus, @votes)
    writer.title = Title
    writer.site_name = SiteName
    writer.site_url = SiteURL
    writer.my_url = MyURL
    writer.write(output)
  end
end

def main()
  output = nil
  opt = OptionParser.new()
  opt.on('-o VAL') {|v| output=v}
  opt.parse!(ARGV)

  output = nil if output == "-"
  input = FileList.new(".")
  contest = Contest.new()

  input.each do |f|
    contest.load(f)
  end

  contest.html(output)
end
main()
