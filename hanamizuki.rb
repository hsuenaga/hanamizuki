#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'optparse'
require 'user_exception'
require 'author'
require 'theme'
require 'vote'
require 'haiku'
require 'rank'
require 'html_writer'

#
# Name Configuration
#
MyURL = "http://www.sakura-mochi.net"
Title = "花水木(平成26年8月)"
SiteName = "花水木"
SiteURL = "http://haiku-hanamizuki.seesaa.net"
DataDir = "./data"

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

class Hanamizuki
  def initialize()
    @file = nil
    @themes = ThemeList.new()
    @authors = AuthorList.new()
    @haikus = HaikuList.new()
    @votes = VoteList.new()

    @cur_voter = nil
    @cur_word = nil
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

  def parse_haiku(composition, author, word)
    author = @authors.append(author) if author
    @haikus.append(@cur_file, composition, author, word)
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
        if a[0] =~ /^「/
          parse_theme(a[0])
          @cur_word = a[0]
        elsif a[0] =~ /選$/
          parse_author(a[0])
          @cur_voter = a[0]
        else
          parse_haiku(a[0], nil, @cur_word)
        end
      when 2
        parse_haiku(a[0], a[1], @cur_word)
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
  hanamizuki = Hanamizuki.new()

  input.each do |f|
    hanamizuki.load(f)
  end

  hanamizuki.html(output)
end
main()
