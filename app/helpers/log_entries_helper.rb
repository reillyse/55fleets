module LogEntriesHelper
  def clean_ansii(x)
    x.gsub(/\e\[(\d+)(;\d+)*m/, '').split('|')
  end
end
