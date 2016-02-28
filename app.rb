#require './router/loader'
require './flickr/loader'

class App < Sinatra::Application

  def initialize
    @pics = {
      'cold': [23577541545]
      'fog': [8469962417, 14919486574]
      'snow': [89074472]
      'cool': [12043895515, 20342715613]
      'warm': [3704273935, 3780893961, 16021074821, 6357276861]
      'hot': [23959664094, 9557006394, 16391611278, 8248259072]
      'really_hot': [19656910812, 5951751285]
      'rain': [6845995798, 9615537120, 6133720797, 15274211811]
    }
    @key = ENV['FLICKR_KEY']
  end

  before do
    content_type 'application/json'
  end

  get '/picture' do
    flickr = FlickrAPI::Proxy.new(@pics, @key)
    temp = params[:temperature].to_i
    condition_id = params[:id_number].to_i
    {
      status: 'ok',
      url: "#{flickr.grab_photo_url(flickr.determine_photo_id(temp, condition_id))}"
    }.to_json
  end

end
