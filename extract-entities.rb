require 'rubygems'
require 'json'
require 'calais'

# now send each of the council meeting notes through Open Calais
Dir.chdir("town-council-minutes")
files = Dir.glob("*.txt")

files.each do |f|
  content = File.new(f).read
  result = Calais.enlighten(:content => content, :content_type => :raw, :output_format => :json, :license_id => "YOUR-KEY-HERE")
  
  # write the json result out to files
  File.open(f+".json", 'w') {|f| f.write(result.to_s) }
end
