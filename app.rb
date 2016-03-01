
require './flickr/loader'

class App < Sinatra::Application

  before do
      content_type 'application/json'
  end

  error 404 do
    Logger.new(STDOUT).error '404 raised'
    {status: '404', msg: 'Hi, did you mistype your URL? Maybe you meant "endpoint/picture"'}.to_json
  end

  error do
   status 500
    Logger.new(STDOUT).fatal '500 raised'
    {status: '500', msg: 'Looks like we done goof\'d'}
  end

  not_found do
    404
  end

  get '/' do
    flickr = FlickrAPI::Proxy.new({
                                      cold: [23577541545],
                                      fog: [8469962417, 14919486574],
                                      snow: [89074472],
                                      cool: [12043895515, 20342715613],
                                      warm: [3704273935, 3780893961, 16021074821, 6357276861],
                                      hot: [23959664094, 9557006394, 16391611278, 8248259072],
                                      really_hot: [19656910812, 5951751285],
                                      rain: [6845995798, 9615537120, 6133720797, 15274211811]
                                  }, ENV['FLICKR_KEY'])
    temp = params[:temperature].to_i
    condition_id = params[:id_number].to_i
    Logger.new(STDOUT).info("Paramters understood to be temp: #{temp} and condition_id: #{condition_id}")
    return {
        status: 'ok',
        url: "#{flickr.grab_photo_url(temp, condition_id)}"
    }.to_json
  end
end

