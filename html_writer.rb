#!/usr/bin/env ruby
CSS_FILE="./css/hanamizuki.css"

class HtmlWriter
  attr_accessor :title, :site_name, :site_url, :my_url
  INDENT_STOP = 4
  def initialize(themes, authors, haikus, votes)
    @themes = themes
    @authors = authors
    @haikus = haikus
    @votes = votes
    @indent = 0
    @flash = nil
    @title = ""
    @site_name = ""
    @site_url = ""
    @my_url = ""
    @outdir = nil
  end

  def haiku_file(haiku)
    "haiku_#{haiku.id}.html"
  end

  def author_file(author)
    "author_#{author.id}.html"
  end

  def theme_file(theme)
    "theme_#{theme.id}.html"
  end

  def word_file(word)
    "word_#{word.id}.html"
  end

  def vote_file()
    "votes_analysis.html"
  end

  def haiku_rank_file()
    "haiku_ranking.html"
  end

  def author_rank_file()
    "author_ranking.html"
  end

  def author_profile_file()
    "author_profile.html"
  end

  def fname2date(fname)
    s = fname.split("-")
    y = s[0].to_i() - 1989 + 1
    m = s[1].to_i()
    "平成#{y}年#{m}月"
  end

  def _fwrite(output, &block)
    return nil unless block

    if output
      fp = File::open(output, "w")
    else
      fp = STDOUT
    end

    block.call(fp)

    if output
      fp.close()
    end
  end

  def indent(f, &block)
    i = 0
    while i < (@indent * INDENT_STOP)
      f.print(" ")
      i += 1
    end
    block.call() if block
  end

  def tag(f, string, &block)
    if @flush
      f.print("\n")
      @flush = false
    end

    @indent += 1
    indent(f) do
      f.print("<#{string}>\n")
    end
    block.call() if block
    f.print("\n")
    indent(f) do
      f.print("</#{string}>")
      @flush = true
    end
    @indent -= 1
  end

  # inline tag
  def write_h1(f, string, &block)
    tag(f, "H1") do
      f.print(string) if string
      block.call() if block
    end
  end

  def write_h2(f, string)
    tag(f, "H2") do
      f.print(string)
    end
  end

  def write_link(f, url, string = nil)
    tag(f, "A href=\"#{url}\"") do
      if string then
        f.print(string)
      else
        f.print(url)
      end
    end
  end

  def write_text(f, string)
    indent(f) do
      f.print(string)
    end
  end

  # block tag
  def write_table(f, css, &block)
    return unless block
    css = "simple" unless css

    tag(f, "TABLE class=\"#{css}\"") do
      block.call()
    end
  end

  def write_p(f, string, &block)
    tag(f, "P") do
      write_text(f, string) if string
      if block
        block.call()
      end
    end
  end

  def write_li(f, string, &block)
    tag(f, "LI") do
      write_text(f, string) if string
      block.call() if block
    end
  end


  def write_ul(f, array, &block)
    tag(f, "UL") do
      if array then
        array.each do |string|
          write_li(f, string)
        end
      end
      if block then
        block.call()
      end
    end
  end

  def write_td_blackout(f, string, &block)
    tag(f, "TD class=\"blackout\"") do
      write_p(f, string) if string
      if block then
        block.call()
      end
    end
  end

  def write_td(f, string, &block)
    tag(f, "TD") do
      write_p(f, string) if string
      if block then
        block.call()
      end
    end
  end

  def write_th(f, string, &block)
    tag(f, "TH") do
      write_p(f, string) if string
      if block then
        block.call()
      end
    end
  end

  def write_tr_th(f, array, &block)
    tag(f, "TR") do
      if array then
        array.each do |string|
          write_th(f, string)
        end
      end
      if block
        block.call()
      end
    end
  end

  def write_tr(f, array, &block)
    tag(f, "TR") do
      if array then
        array.each do |string|
          write_td(f, string)
        end
      end
      if block
        block.call()
      end
    end
  end

  def write_hr(f, style = nil)
    write_text(f, "\n")
    indent(f) do
      if style then
        write_text(f, "<HR class=\"#{style}\"/>")
      else
        write_text(f, "<HR/>")
      end
    end
  end

  ## content
  def write_site_description(f)
    write_h1(f, @title)
    write_p(f, nil) do
      write_link(f, @site_url)
    end
  end

  def write_author_link(f, author)
    author_link = "#{@my_url}/#{author_file(author)}"
    write_link(f, author_link, author.name)
  end

  def write_authors(f)
    write_h1(f, "俳号")
    write_hr(f, "shadow_down")
    write_table(f, "simple") do
      write_tr_th(f, ["俳号", "プロフィール"])
      @authors.each do |author|
        write_tr(f, nil) do
          write_td(f, nil) do
            write_author_link(f, author)
          end
          write_td(f, author.profile)
        end
      end
    end
  end

  def write_theme_link(f, theme)
    date = fname2date(theme.fname)
    theme_link = "#{@my_url}/#{theme_file(theme)}"
    write_link(f, theme_link, date)
  end

  def write_word_link(f, word)
    word_link = "#{@my_url}/#{word_file(word)}"
    write_link(f, word_link, word.string)
  end

  def write_themes(f)
    write_table(f, "theme") do
      write_tr_th(f, ["投句月", "季題", "優勝", "優勝得点", "投句数"])
      @themes.each do |theme|
        write_tr(f, nil) do
          write_td(f, nil) do
            write_theme_link(f, theme)
          end
          write_td(f, nil) do
            write_ul(f, nil) do
              theme.each do |word|
                write_li(f, nil) do
                  write_word_link(f, word)
                end
              end
            end
          end
          write_td(f, nil) do
            author = @authors.byname(theme.winner)
            write_author_link(f, author) if author
          end
          write_td(f, theme.winner_point)
          write_td(f, @haikus.count_by_fname(theme.fname))
        end
      end
    end
  end

  def write_theme_file(theme)
    return unless @outdir
    theme_file = "#{@outdir}/#{theme_file(theme)}"
    _fwrite(theme_file) do |f|
      write_header(f)

      write_h1(f, fname2date(theme.fname))
      write_hr(f, "shadow_down")
      write_ul(f, nil) do
        theme.each() do |word|
          write_li(f, nil) do
            write_word_link(f, word)
          end
        end
      end
      write_hr(f, "shadow_down")
      write_table(f, "simple") do
        write_tr_th(f, ["俳句", "俳号", "得点"])
        @haikus.each_by_fname(theme.fname) do |haiku|
          write_tr(f, nil) do
            write_td(f, nil) do
              write_haiku_link(f, haiku)
            end
            write_td(f, nil) do
              if haiku.author
                write_author_link(f, haiku.author)
              else
                write_text(f, "選考中")
              end
            end
            write_td(f, haiku.point)
          end
        end
      end

      write_footer(f)
    end
  end

  def write_word_file(word)
    return unless @outdir
    word_file = "#{@outdir}/#{word_file(word)}"
    _fwrite(word_file) do |f|
      write_header(f)

      write_h1(f, word.string)
      write_hr(f, "shadow_down")
      write_theme_link(f, word.theme)
      write_table(f, "simple") do
        write_tr_th(f, ["俳句", "俳号", "得点"])
        @haikus.each_by_word(word.string) do |haiku|
          write_tr(f, nil) do
            write_td(f, nil) do
              write_haiku_link(f, haiku)
            end
            write_td(f, nil) do
              if haiku.author
                write_author_link(f, haiku.author)
              else
                write_text(f, "選考中")
              end
            end
            write_td(f, haiku.point)
          end
        end
      end

      write_footer(f)
    end
  end

  def write_authors_ranking(f, limit = nil)
    write_p(f, <<EOS)
これまでの互選で各作者が獲得した得点の集計です。参加期間による調整はしていないので、途中参加だったりお休み期間があったりすると低くなります。
EOS
    write_p(f, <<EOS)
得点は、天=4点、地=3点、人=2点、佳作=1点として計算しています。
EOS
    write_table(f, "simple") do
      write_tr_th(f, ["順位", "俳号", "得点"])
      rank = 1
      @authors.sort_by_point() do |author|
        write_tr(f, nil) do
          write_td(f, rank)
          write_td(f, nil) do
            write_author_link(f, author)
          end
          write_td(f, author.point)
        end
        rank += 1
        break if limit && rank > limit
      end
    end
  end

  def write_author_rank_file()
    return unless @outdir
    author_rank_file = "#{@outdir}/#{author_rank_file()}"
    _fwrite(author_rank_file) do |f|
      write_header(f)
      write_h1(f, "個人総合成績")
      write_hr(f, "shadow_down")
      write_authors_ranking(f)
      write_footer(f)
    end
  end

  def write_author_profile_file()
    return unless @outdir
    author_profile_file = "#{@outdir}/#{author_profile_file()}"
    _fwrite(author_profile_file) do |f|
      write_header(f)
      write_authors(f)
      write_footer(f)
    end
  end

  def write_author_file(author)
    return unless @outdir
    author_file = "#{@outdir}/#{author_file(author)}"
    _fwrite(author_file) do |f|
      write_header(f)

      write_h1(f, author.name)
      write_hr(f, "shadow_down")
      write_p(f, author.profile)
      write_table(f, "simple") do
        write_tr_th(f, ["俳句", "得点", "開催月"])
        @haikus.each_by_author(author) do |haiku|
          write_tr(f, nil) do
            write_td(f, nil) do
              write_haiku_link(f, haiku)
            end
            write_td(f, haiku.point)
            theme = @themes.byfname(haiku.fname)
            write_td(f, nil) do
              write_theme_link(f, theme)
            end
          end
        end
      end

      write_footer(f)
    end
  end

  def write_haiku_link(f, haiku)
    haiku_link = "#{@my_url}/#{haiku_file(haiku)}"
    write_link(f, haiku_link, haiku.composition)
  end

  def write_haiku_ranking(f, limit = nil)
    write_p(f, <<EOS)
これまでに投句された各俳句が獲得した得点の集計です。
EOS
    write_table(f, "simple") do
      write_tr_th(f, ["順位", "俳句", "俳号", "得点", "開催月"])
      rank = 1
      @haikus.sort_by_point() do |haiku|
        write_tr(f, nil) do
          author = haiku.author
          write_td(f, rank)
          write_td(f, nil) do
            write_haiku_link(f, haiku)
          end
          write_td(f, nil) do
            if author
              write_author_link(f, author)
            else
              write_text(f, "選考中")
            end
          end
          write_td(f, haiku.point)
          theme = @themes.byfname(haiku.fname)
          write_td(f, nil) do
            write_theme_link(f, theme)
          end
        end
        rank += 1
        break if limit && rank > limit
      end
    end
  end

  def write_haiku_rank_file()
    return unless @outdir
    haiku_rank_file = "#{@outdir}/#{haiku_rank_file()}"
    _fwrite(haiku_rank_file) do |f|
      write_header(f)
      write_h1(f, "俳句別総合成績")
      write_hr(f, "shadow_down")
      write_haiku_ranking(f)
      write_footer(f)
    end
  end

  def write_haiku_file(haiku)
    return unless @outdir
    haiku_file = "#{@outdir}/#{haiku_file(haiku)}"
    _fwrite(haiku_file) do |f|
      author = haiku.author
      write_header(f)
      write_h1(f, nil) do
        write_text(f, "#{haiku.composition}<br>")
        if author
          write_text(f, "−#{author.name}")
        else
          write_text(f, "−選考中")
        end
      end
      write_hr(f, "shadow_down")
      theme = @themes.byfname(haiku.fname)
      write_ul(f, nil) do
        write_li(f, nil) do
          write_theme_link(f, theme)
        end
        write_li(f, nil) do
          write_word_link(f, @themes.getword(haiku.word))
        end
      end
      write_h2(f, "選句")
      write_table(f, nil) do
        write_tr_th(f, ["評価", "俳号"])
        @votes.each_by_haiku(haiku) do |vote|
          write_tr(f, nil) do
            write_td(f, vote.rank_str())
            write_td(f, nil) do
              write_author_link(f, vote.from)
            end
          end
        end
      end
      write_footer(f)
    end
  end

  def write_vote_file()
    return unless @outdir
    vote_file = "#{@outdir}/#{vote_file()}"
    _fwrite(vote_file) do |f|
      write_header(f)

      write_h1(f, "選句率表")
      write_hr(f, "shadow_down")
      write_p(f, <<EOS)
  誰が誰の俳句を選ぶ傾向があるかの集計です。各選句者がこれまでの選句で投票した全得点に対する、各投句者への投票の割合を出しています。極端な例を除き、参加期間の影響は少なくなります。
EOS
      write_p(f, <<EOS)
  表を左から右にたどると、選句者が誰に投票する傾向があるか分かります。上から下にたどると、投句者が誰に選ばれる傾向があるか分かります。
EOS
      write_table(f, "score_sheet") do
        write_tr_th(f, nil) do
          write_th(f, "")
          @authors.each do |author|
            write_th(f, author.name)
          end
        end

        @authors.each do |voter|
          write_tr(f, nil) do 
            write_td(f, nil) do
              write_author_link(f, voter)
            end
            @authors.each do |author|
              if author == voter then
                write_td_blackout(f, "")
              else
                write_td(f, voter.vote_ratio(author))
              end
            end
          end
        end
      end
      write_footer(f)
    end
  end

  def write_css(f)
    f.print("<STYLE type=\"text/css\"><!--\n")
    File::open(CSS_FILE) do |css|
      css.each do |line|
        f.print(line)
      end
    end
    f.print("--></STYLE>\n")
  end

  def write_header(f, omit_link = false)
    f.print(<<EOS)
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=shift_jis">
<META name="generator" content="hanamizuki.rb">
<META name="description" content="句会 花水木">
<link rel="shortcut icon" href="http://sakura-mochi.net/favicon.png" type="image/vnd.microsoft.icon" />
<link rel="icon" href="http://sakura-mochi.net/favicon.png" type="image/vnd.microsoft.icon" />
EOS
    f.print("<TITLE>#{@site_name}</TITLE>\n")
    write_css(f)
    f.print(<<EOS)
</HEAD>

<BODY>
EOS
  f.print("<A href=\"#{@my_url}\">TOPページ</A>\n") unless omit_link
  f.print("<HR class=\"simple\"/>\n")
  end

  def write_footer(f, omit_link = false)
    f.print("<HR class=\"simple\"/>\n")
    f.print("<A href=\"#{@my_url}\">TOPページ</A>\n") unless omit_link
    f.print(<<EOS)
</BODY>
</HTML>
EOS
  end

  def write(outdir)
    @outdir = outdir
    output = nil
    if @outdir
      if !File::directory?(@outdir)
        print("Direcotry not found: #{@outdir}\n")
        raise RuntimeError
      end
      output = "#{@outdir}/index.html"
    end

    ## main contents
    _fwrite(output) do |f|
      write_header(f, true)

      write_site_description(f)
      write_hr(f, "shadow_down")

      write_h1(f, "季題")
      write_themes(f)
      write_hr(f, "shadow_down")

      write_h1(f, "個人総合成績(TOP 10)")
      write_authors_ranking(f, 10)
      write_ul(f, nil) do
        write_li(f, nil) do
          write_link(f, "#{@my_url}/#{author_rank_file()}", "全成績")
        end
        write_li(f, nil) do
          write_link(f, "#{@my_url}/#{author_profile_file()}", "俳号一覧")
        end
      end
      write_hr(f, "shadow_down")

      write_h1(f, "俳句別総合成績(TOP 10)")
      write_haiku_ranking(f, 10)
      write_ul(f, nil) do
        write_li(f, nil) do
          write_link(f, "#{@my_url}/#{haiku_rank_file()}", "全成績")
        end
      end
      write_hr(f, "shadow_down")

      write_h1(f, "選句の傾向")
      write_ul(f, nil) do
        write_li(f, nil) do
          write_link(f, "#{@my_url}/#{vote_file()}", "選句率表")
        end
      end
      write_hr(f, "shadow_down")

      write_footer(f, true)
    end

    @haikus.each() do |haiku|
      write_haiku_file(haiku)
    end

    @authors.each() do |author|
      write_author_file(author)
    end

    @themes.each() do |theme|
      write_theme_file(theme)
    end

    @themes.each_word() do |word|
      write_word_file(word)
    end

    write_vote_file()
    write_author_rank_file()
    write_author_profile_file()
    write_haiku_rank_file()
  end
end
