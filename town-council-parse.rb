require 'rubygems'
require 'typhoeus'
require 'nokogiri'
require 'uri'
require 'json'
require 'calais'

BASE_URL = 'http://www.ci.watertown.ma.us'

# the request object
response = Typhoeus::Request.get(BASE_URL+"/Archive.aspx", :params => {:AMID => "36"})

puts "REQUESTING DOCUMENTS FROM WATERTOWN WEBSITE"
puts response.code    # http status code
puts response.time    # time in seconds the request took

begin
  archive = Nokogiri::HTML(response.body)

  archive.css('span.archive a').each_with_index do |node, index|
    if (index > 0)
      document_url = BASE_URL+"/"+node['href']
      puts document_url
    
      document_response = Typhoeus::Request.get(document_url)
      doc = Nokogiri::HTML(document_response.body)

      document_link = BASE_URL + doc.css('span.archive a')[0]['href']
    
      file_url = URI.escape(document_link)
      puts "DOWNLOADING: " + file_url
      system("mkdir town-council-minutes")
      system("cd town-council-minutes > /dev/null ; curl -O "+file_url)
    end
  end

rescue Nokogiri::XML::SyntaxError => e
  puts "caught exception: #{e}"
end

# convert all the PDFs to text
Dir.chdir("town-council-mintes")
files = Dir.glob("*.pdf")

files.each do |f|
  system("pdftotext "+f)
end

# now send each of the PDFs through Open Calais
Dir.chdir("town-council-mintes")
files = Dir.glob("*.txt")

files.each do |f|
  result = Calais.enlighten(:content => content, :content_type = :raw, output_format => :json, :license_id = "r6q88uv3d2pwjfrsr4e8d9j5")
  
  # write the json result out to files
  File.open(f+".json", 'w') {|f| f.write(result.to_s) }
end



#ruby-1.9.2-p180 :051 > quotes.each do |q|
#ruby-1.9.2-p180 :052 >     name = Siren.query "$[q['person']]", parsed
#ruby-1.9.2-p180 :053?>   puts "FROM: "+ name
#ruby-1.9.2-p180 :054?>   puts "QUOTE: "+ q["quote"]
#ruby-1.9.2-p180 :055?>   end

