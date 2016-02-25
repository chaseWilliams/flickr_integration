#require './router/loader'
require './flickr/flickr'
require 'redis'
require 'sinatra'
flickr = Flickr.new
#class App < Sinatra::Application
#  def initialize
    db = Redis.new
    db.set 'cold', [23577541545].to_json
    db.set 'fog', [8469962417, 14919486574].to_json
    db.set 'snow', [89074472].to_json
    db.set 'cool', [12043895515, 20342715613].to_json
    db.set 'warm', [3704273935, 3780893961, 16021074821, 6357276861].to_json
    db.set 'hot', [23959664094, 9557006394, 16391611278, 8248259072].to_json
    db.set 'really_hot', [19656910812, 5951751285].to_json
    db.set 'rain', [6845995798, 9615537120, 6133720797, 15274211811].to_json
    puts 'Redis done!'
#  end
  # Remember that this is a helper function that will process each request (regardless of endpoint) before
  # processing the get/post/put sections below
  before do
    content_type 'application/json'
    # [...other code will go here, if needed...]
  end

  # You'll repeat this for each endpoint this app will host and for each HTTP method
  get '/picture' do
    # [...your code will go here...]
    temp = params[:temperature]
    condition_id = params[:id_number].to_i
    {status: 'ok', data: "#{flickr.grab_photo_url(flickr.determine_photo_id(temp, condition_id))}"}.to_json
  end

#end
