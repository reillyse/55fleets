class ColourBlind

  def self.clean(string)
    string.gsub(/\e\[(\d+)m/, "")
  end

end
