#flickr.rb
require 'rest-client'

#grabs the image url of a pre-specified photo id using Flickr's API.
module Flickrd
  def grab_photo_url photo_id
    response = JSON.parse (RestClient.get "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=3a86e2e6e0552b135fa3830f8421d07e&format=json&photo_id=#{photo_id}&nojsoncallback=?")
    img_index = nil #default value

    #determines what's the index of the 'Large' image.
    response['sizes']['size'].each_with_index {|k, i| if k['label'] == 'Large' then img_index = i; break end}
    if img_index.nil? #in case img_index wasn't affected.
       "https://farm7.staticflickr.com/6217/6357276861_1fdc6fe3d4_b.jpg"
    else
       response['sizes']['size'][img_index]['source']
    end
  end

  def getImg(temp, id) #compares with weather condition codes
    #weather conditions first; highest priority.
    is_foggy = false
    [701, 721, 741].each {|k| if k == id then is_foggy = true;puts 'yes' end}

    if (id >= 200 && id < 600) #rain?
      determine_photo_id @rain[rand(@rain.length)-1]
    elsif id >= 600 && id < 700#snow?
       determine_photo_id @snow[rand(@snow.length)-1]
    elsif (is_foggy) #fog?
       determine_photo_id @fog[rand(@fog.length)-1]
    elsif temp <= 10 #cold?
       determine_photo_id @cold[rand(@cold.length)-1] #this mechanism returns a random photo id from the array.
    elsif temp <= 40 #cool?
       determine_photo_id @cool[rand(@cool.length)-1]
    elsif temp <= 75 #warm?
       determine_photo_id @warm[rand(@warm.length)-1]
    elsif temp <= 100#hot?
       determine_photo_id @hot[rand(@hot.length)-1]
    else #probably really hot then.
       determine_photo_id @really_hot[rand(@really_hot.length)-1]
    end
  end
  module_function :grab_photo_url, :determine_photo_id
end


module ISource
  # NEED TO MOVE TO REDIS
  @cold = [23577541545]
  @fog = [8469962417, 14919486574]
  @snow = [89074472]
  @cool = [12043895515, 20342715613]
  @warm = [3704273935, 3780893961, 16021074821, 6357276861]
  @hot = [23959664094, 9557006394, 16391611278, 8248259072]
  @really_hot = [19656910812, 5951751285]
  @rain = [6845995798, 9615537120, 6133720797, 15274211811]
  module_function :getImg
end
