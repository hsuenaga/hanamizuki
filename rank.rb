#
# Rank Configuration
#
class Rank
  RankDef = {
    "天" => 4,
    "地" => 3,
    "人" => 2,
    "佳作" => 1
  }

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


