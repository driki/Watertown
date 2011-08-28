require 'rubygems'
require 'json'
require 'csv'
require 'siren'

# now send each of the council meeting notes through Open Calais
Dir.chdir("town-council-minutes")
files = Dir.glob("*.json")

# Create the output file
CSV.open("quotes.csv", "wb") do |csv|

  csv << ["DATE", "NAME", "PERSON_ID", "QUOTE"]

  files.each do |f|
    content = File.new(f).read
    puts f
    data = Siren.parse(content)

    date = Siren.query "$.doc.info.docDate", data
    quotes = Siren.query "$[? @._type = 'Quotation' ]", data

    quotes.each do |q|

      quote_row = Array.new
      quote_row << date
      
      person_id = q["person"]
      puts person_id
      person_name = data[person_id]["name"]
      quote_row << person_name

      quote = q["instances"][0]["exact"]
      if quote.nil?
        quote = q["quote"]
      end

      puts date + ", " + person_name + ", " + person_id + ", " + quote

      quote_row << person_id
      quote_row << quote
      
      csv << quote_row
    end
  end
end