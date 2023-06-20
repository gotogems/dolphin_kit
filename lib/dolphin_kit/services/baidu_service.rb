require 'digest/md5'

module DolphinKit
  class BaiduService
    BASE_URL = 'https://fanyi-api.baidu.com/api/trans'

    def initialize(app_id: nil, app_key: nil, endpoint: nil)
      @endpoint = "#{BASE_URL}/vip/translate"
      @app_id, @app_key = app_id, app_key
    end

    def call(text:, source: 'auto', target: nil)
      target ||= (LANGUAGES.keys - [source.to_sym]).first

      params = { from: source, to: LANGUAGES[target.to_sym] }
      params.merge!(build_params(text))

      response = HTTP.post(@endpoint, form: params)
      result = JSON.parse(response.body)

      if (code = result['error_code'].to_i) > 52000
        @failure = FAILURES[code]
      else
        @failure = nil
      end

      result
    end

    private

    def build_params(value)
      salt = Time.now.to_i.to_s
      args = [@app_id, value, salt, @app_key]

      {
        appid: @app_id,
        sign: sign(*args),
        salt: salt,
        q: value
      }
    end

    def sign(*args)
      Digest::MD5.hexdigest(args.join)
    end

    LANGUAGES = {
      en: 'en',
      zh: 'zh',
      ja: 'jp',
      ko: 'kor',
      es: 'spa',
      de: 'de',
      fr: 'fra',
      vi: 'vie',
      th: 'th',
      ar: 'ara',
      hi: 'hi',
      id: 'id',
      it: 'it',
      ms: 'may',
      pt: 'pt',
      ru: 'ru',
      tr: 'tr',
      'zh-TW': 'cht'
    }

    FAILURES = {
      52001 => '请求超时',
      52002 => '系统错误',
      52003 => '未授权用户',
      54000 => '必填参数为空',
      54001 => '签名错误',
      54003 => '访问频率受限',
      54004 => '账户余额不足',
      54005 => 'Query 请求频繁',
      58000 => '客户端 IP 非法',
      58001 => '译文语言方向不支持',
      58002 => '服务当前已关闭',
      90107 => '认证未通过或未生效'
    }
  end
end
