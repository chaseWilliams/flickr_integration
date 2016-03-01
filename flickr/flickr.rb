module FlickrAPI
  class Proxy
    def initialize(pics, key)
      @pics = pics
      @key = '3a86e2e6e0552b135fa3830f8421d07e'
      @endpoint = 'api.flickr.com/services/rest'
      @method = 'method=flickr.photos.getSizes'
      @redis = Redis.new(url: ENV['REDIS_URI'])
      @logger_out = Logger.new(STDOUT)
      @logger_err = Logger.new(STDERR)
    end

    def grab_photo_url temp, condition_id
      photo_id = determine_photo_id temp, condition_id
      @logger_out.info 'determine_photo_id called, successfully completed.'

      url = "https://#{@endpoint}/?#{@method}&api_key=#{@key}&format=json&photo_id=#{photo_id}&nojsoncallback=?"
      @logger_out.info "no existing url, about to send GET request to #{url}"
      response = JSON.parse RestClient::Request.execute(
                                url: url,
                                method: :get,
                                verify_ssl: false,
                            )
      @logger_out.info "Response is #{response.class}, #{response}. First level is #{response['sizes'].class}"
      index = nil #default value
      #determines what's the index of the 'Large' image.
      response['sizes']['size'].each_with_index {|k, i| if k['label'] == 'Large' then index = i; break end}
      if index.nil? #in case img_index wasn't affected, implying no Large image was found
         "https://farm7.staticflickr.com/6217/6357276861_1fdc6fe3d4_b.jpg"
      else
         picture_url = response['sizes']['size'][index]['source']
      end

      @redis.set(photo_id, picture_url)
      @logger_out.info "Set the url #{picture_url} for photo id #{photo_id} in Redis"

      photo_url = @redis.get photo_id
      @logger_out.info "Got the url #{photo_url}"
      photo_url
      end

    private
    def get_photo(key)
      @pics[key.to_sym]
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
      if id >= 200 && id < 600 #rain?
        photo_id_helper rain
      elsif id >= 600 && id < 700#snow?
        photo_id_helper snow
      elsif is_foggy #fog?
        photo_id_helper fog
      elsif temp <= 10 #cold?
        photo_id_helper cold #this mechanism returns a random photo id from the array.
      elsif temp <= 40 #cool?
        photo_id_helper cool
      elsif temp <= 75 #warm?
        photo_id_helper warm
      elsif temp <= 100#hot?
        photo_id_helper hot
      else #probably really hot then.
        photo_id_helper really_hot
      end
    end

    def photo_id_helper arr
      photo_id = arr[rand(arr.length)-1]
      @logger_out.info "selected the photo id #{photo_id}"
      photo_id
    end
  end
end
