require 'nokogiri'
require 'rest-client'
require 'httparty'
require 'byebug'
require 'pry'

class Scraper

    attr_reader :url, :make, :model

    def initialize (make, model)
     @make = make.capitalize
     @model = model.capitalize
     @url = "https://www.dupontregistry.com/autos/results/#{make}/#{model}/for-sale".sub(" ", "--")
    end 

def parse_url(url)
    unparsed_page = HTTParty.get(url)
    Nokogiri::HTML(unparsed_page)
end 

 def scrape 
 parsed_page = parse_url(@url)

  cars = parsed_page.css('div.searchResults') #Nokogiri object containing all cars on a given page

  per_page = cars.count #counts the number of cars on each page, should be 10
  total_listings = parsed_page.css('#mainContentPlaceholder_vehicleCountWithin').text.to_i
  total_pages = self.get_number_of_pages(total_listings, per_page)

 first_page = create_car_hash(cars)
 all_other = build_full_cars(total_pages)
 first_page + all_other.flatten
 binding.pry

 end 

 def create_car_hash(car_obj)

    car_obj.map { |car|

    {
        year: car.css('a').children[0].text[0..4].strip.to_i,
        name: @make,
        model: @model,
        price: car.css('.cost').children[1].text.sub(",","").to_i,
        link: "https://www.dupontregistry.com/#{car.css('a').attr('href').value}"
    }

   }

end 

def get_all_page_urls(array_of_ints)
    array_of_ints.map { |number| 
     @url + "/pagenum=#{number}"
  }
end 

def get_number_of_pages(listings, cars_per_page)
 a = listings % cars_per_page
 if a == 0
    listings / cars_per_page
 else 
    listings / cars_per_page + 1
 end 

end 

def build_full_cars(number_of_pages)
 a = [*2..number_of_pages]
 all_page_urls = get_all_page_urls(a)

 all_page_urls.map { |url| 
 pu = parse_url(url)
 cars = pu.css('div.searchResults')
 create_car_hash(cars)
}

end 

binding.pry

end 