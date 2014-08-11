#
# Exception
#
class DuplicatedHaiku < Exception; end
class HaikuNotFound < Exception; end
class ParseError < Exception; end
class InvalidRank < Exception; end
class InvalidFname < Exception; end
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
  when InvalidFname
    print("季題が見つからない")
  else
    print("未定義エラー")
  end
  print(": ファイル #{file}.txt: #{line} 行目\n")
  print("#{string}\n")
  exit
end


