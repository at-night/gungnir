require 'sinatra'
require 'redis'
require "json"

redis = Redis.new(:url => ENV['REDIS_URL'])

get '/:app_secret/:gungnir_id/:gungnir_secret' do

	halt 401, "Not Authorized" and return unless params['app_secret'] == ENV['APP_SECRET'] or ENV['APP_SECRET'].nil?

	id = 		params.delete("gungnir_id")
	secret = 	params.delete("gungnir_secret")

	redis_key = "#{id}:#{secret}"

	objs = redis.LRANGE redis_key, 0, -1 
	x = redis.DEL redis_key
	
	res = []
	
	objs.each do |s|
		res << JSON.parse(s)
	end

	res.to_json

end

post '/:gungnir_id/:gungnir_secret' do

	id = 		params.delete("gungnir_id")
	secret = 	params.delete("gungnir_secret")

	hash = {
		time: Time.now().to_i,
		data: params
	}

	redis.LPUSH "#{id}:#{secret}", hash.to_json

	"ok"
end


get "/" do 
	"ok"
end