module EntriesHelper

  def display_total(i)
    begin
      min = (i / 6000).to_i
      sec = sprintf("%.2f", (i / 100.00) - (min * 60))
      if min == 0
        "#{sec}"
      else
        "#{min}:#{sec}"
      end
    rescue
      "DNF"
    end
  end

end
