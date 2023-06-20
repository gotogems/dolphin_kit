module DolphinKit
  class Service
    attr_reader :name

    def initialize(name = 'youdao', client_id: nil, client_secret: nil, api_key: '')
      @name, @client_id, @client_secret = name.to_sym, client_id, client_secret

      if @client_id.nil? and @client_secret.nil?
        @client_id, @client_secret = api_key.split(':')
      end

      @instance = build_instance
    end

    def call(**args)
      @instance.call(**args)
    end

    private

    def build_instance
      case @name
      when :baidu
        BaiduService.new(app_id: @client_id, app_key: @client_secret)
      when :qcloud
        QCloudService.new(app_id: @client_id, app_key: @client_secret)
      else
        @name = :youdao
        YoudaoService.new(keyfrom: @client_id, key: @client_secret)
      end
    end
  end
end
