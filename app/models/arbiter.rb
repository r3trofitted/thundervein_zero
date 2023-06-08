class Arbiter
  def self.parse_command(input)
    case input
     when /^join$/i then "join"
     when /^(move|attack|order)$/i then "order"
     else ""
    end.inquiry
  end
end
