require 'rubygems'
require 'csv'
require 'typhoeus'
require 'json'


GOOGLE_GEO_URL = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="

# Create the output file
CSV.open("geo-coded-permits.csv", "wb") do |csv|

    csv << ["address", "description", "lat", "lng"]


  # open up the zip code csv file
  CSV.foreach("building-permits.csv") do |row|
    
    info = Array.new
    
    # for each record in the csv perform this action
     number = row[0]
     street = row[1]
     description = row[2]
   
     if !number.nil? && !street.nil?
       address = number.strip + ", " + street.strip + ", " + "Watertown, MA, 02472"
       puts address
       info << address
       info << description
       
       # the request object
       response = Typhoeus::Request.get(GOOGLE_GEO_URL, :params => {:address => address})

       puts "GEO CODING FOR ADDRESS: "+address
       puts response.code    # http status code
       puts response.time    # time in seconds the request took

       data = JSON.parse(response.body)
      
       lat = data['results'][0]['geometry']['location']['lat']
       lng = data['results'][0]['geometry']['location']['lng']
      
       puts lat
       puts lng

       info << lat
       info << lng

       sleep(1)
       
       csv << info
     end
  end
end