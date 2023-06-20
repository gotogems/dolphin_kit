require 'json'
require 'dolphin_kit/version'
require 'dolphin_kit/helpers/http'
require 'dolphin_kit/services/baidu_service'
require 'dolphin_kit/services/qcloud_service'
require 'dolphin_kit/services/youdao_service'
require 'dolphin_kit/service'

module DolphinKit
  module_function

  def create_service(name, **args)
    if args.empty?
      args[:api_key] = ENV["#{name}_FANYI_API_KEY".upcase].to_s
    end

    Service.new(name, **args)
  end
end
