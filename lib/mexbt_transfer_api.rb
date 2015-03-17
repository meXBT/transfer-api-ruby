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
      raise "Api key cannot be null" if @api_key.nil?
      raise "Api secret cannot be null" if @api_secret.nil?
      raise "Client id cannot be null" if @client_id.nil?
    end

    def create_order(in_currency:, out_currency:, out_via:, webhook:, in_amount: 0, out_amount: 0,
                     sender_info: {}, recipient_info: {}, skip_deposit_address_setup: false)
      raise "You must specify a value for either in or out" if in_amount.nil? && out_amount.nil?
      params = {
        in_currency: in_currency,
        out_currency: out_currency,
        out_via: out_via,
        webhook: webhook,
        sender_info: sender_info,
        recipient_info: recipient_info,
        skip_deposit_address_setup: skip_deposit_address_setup
      }
      amounts = {
        in: in_amount,
        out: out_amount
      }
      [:in, :out].each do |a|
        amount = amounts[a]
        if amount && amount.kind_of?(String)
          amounts[a] = BigDecimal.new(amount)
        end
      end
      if amounts[:in] > 0
        params[:in] = amounts[:in]
      elsif amounts[:out] > 0
        params[:out] = amounts[:out]
      end
      call("/orders", params)
    end

    def get_order(id)
      call("/orders/#{id}")
    end

    def modify_order(id, params)
      call("/orders/#{id}/modify", params)
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
