require 'rubygems'
require 'typhoeus'
require 'nokogiri'
require 'uri'

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
      system("curl -O "+file_url)
    end
  end

rescue Nokogiri::XML::SyntaxError => e
  puts "caught exception: #{e}"
end