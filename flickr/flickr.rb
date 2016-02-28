module FlickrAPI
  class Proxy
    def initialize(pics, key)
      @pics = pics
      @key = key
      @endpoint = 'api.flickr.com/services/rest'
      @method = 'method=flickr.photos.getSizes'
      @redis = Redis.new(url: ENV['REDIS_URI'])
    end

    def grab_photo_url id
      if @redis.exists(id) == 0
        url = "https://#{@endpoint}/?#{@method}&api_key=#{@key}&format=json&photo_id=#{id}&nojsoncallback=?"
        response = JSON.parse RestClient::Request.execute(
                                  url: url,
                                  method: :get,
                                  verify_ssl: false,
                              )
        index = nil #default value

        #determines what's the index of the 'Large' image.
        response['sizes']['size'].each_with_index {|k, i| if k['label'] == 'Large' then index = i; break end}
        if index.nil? #in case img_index wasn't affected.
           "https://farm7.staticflickr.com/6217/6357276861_1fdc6fe3d4_b.jpg"
        else
           picture_url = response['sizes']['size'][index]['source']
        end
        @redis.set(id, picture_url)
      else
        @redis.get(id)
    end

    def get_photo(key)
      @pics[key]
    end

    def determine_photo_id(temp, id)
      is_foggy = false
      [701, 721, 741].each {|k| if k == id then is_foggy = true end}

      # Get pictures IDs based on weather type
      rain = get_photo('rain')
      snow = get_photo('snow')
      fog = get_photo('fog')
      cold = get_photo('cold')
      cool = get_photo('cool')
      warm = get_photo('warm')
      hot = get_photo('hot')
      really_hot = get_photo('really_hot')

      # Evaluate weather condition based on condition_id
      # Compares with weather condition codes
      # Weather conditions first; highest priority.
      if (id >= 200 && id < 600) #rain?
        rain[rand(rain.length)-1]
      elsif id >= 600 && id < 700#snow?
        snow[rand(snow.length)-1]
      elsif (is_foggy) #fog?
        fog[rand(fog.length)-1]
      elsif temp <= 10 #cold?
        cold[rand(cold.length)-1] #this mechanism returns a random photo id from the array.
      elsif temp <= 40 #cool?
        cool[rand(cool.length)-1]
      elsif temp <= 75 #warm?
        warm[rand(warm.length)-1]
      elsif temp <= 100#hot?
        hot[rand(hot.length)-1]
      else #probably really hot then.
        really_hot[rand(really_hot.length)-1]
      end
    end
  end
end
