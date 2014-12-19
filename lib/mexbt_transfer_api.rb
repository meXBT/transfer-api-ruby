require 'rest_client'
require 'active_support/core_ext/hash/indifferent_access'
require 'json'

module Mexbt
  class TransferApi
    DEFAULT_ENDPOINT = "https://transfer.mexbt.com/v1"
    SSL_VERSION = :TLSv1_2

    def initialize(api_key, api_secret, client_id, endpoint: DEFAULT_ENDPOINT)
      @api_key = api_key
      @api_secret = api_secret
      @client_id = client_id
      @endpoint = endpoint
    end

    def create_order(in_currency:, out_currency:, out_via:, webhook:, in_amount: 0, out_amount: 0, sender_info: {}, recipient_info: {})
      params = {
        in_currency: in_currency,
        out_currency: out_currency,
        out_via: out_via,
        webhook: webhook,
        sender_info: sender_info,
        recipient_info: recipient_info
      }
      if in_amount > 0
        params[:in] = in_amount
      elsif out_amount > 0
        params[:out] = out_amount
      else
        raise "You must specify a value for either in or out"
      end
      call("/orders", params)
    end

    def get_order(id)
      call("/orders/#{id}")
    end

    def ping
      call("/ping")
    end

    private

    def url(path)
      "#{@endpoint}#{path}"
    end

    def call(path, params={})
      url = url(path)
      params.merge!(auth_params)
      res = RestClient::Request.execute(method: :post, url: url, payload: params.to_json, ssl_version: SSL_VERSION, headers: { content_type: :json, accept: :json }) do |response, request, result|
        case response.code
        when 200, 400
          response
        else
          response.return!(request, result)
        end
      end
      ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(res))
    end

    def auth_params
      nonce = (Time.now.to_f*10000).to_i
      {
        api_key: @api_key,
        nonce: nonce,
        signature: OpenSSL::HMAC.hexdigest('sha512', @api_secret, "#{nonce}#{@client_id}#{@api_key}").upcase
      }
    end

  end
end