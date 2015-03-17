require "spec_helper"

describe Mexbt::TransferApi do

  subject(:transfer_api) do
    Mexbt::TransferApi.new("e22a52802d6db99d524f51a93a413536", "3bf5501c8149958a3e2494e1f0f24f5a71a52a80248198bf0f1c6570fc89e095", 1, endpoint: "http://localhost:3000/v1")
  end

  context "ping", :vcr do
    it "returns a 200 response if authentication successful" do
      expect(transfer_api.ping).to eql({ "ok" => true })
    end
  end

  context "creating orders", :vcr do
    it "allows creating a btc -> mxn transfer order for 5000 pesos, cashed out via ATM" do
      res = transfer_api.create_order(in_currency: 'btc', out_currency: 'mxn', out_amount: 5000, out_via: 'atm', webhook: 'http://requestb.in/11rzly71')
      expect(res).to eql({
        "id"=>6,
        "in"=>{"currency"=>"btc", "amount"=>1.15173726},
        "out"=>{"currency"=>"mxn", "amount"=>5000.0},
        "out_via"=>"atm",
        "sender_info"=>nil,
        "recipient_info"=>nil,
        "withdraw_info"=>nil,
        "quote_valid_until"=>1418916655,
        "deposit_info"=>{"address"=>"ByNafb7C39BB7JqdkSVFUPzJoGsumUA4ks"},
        "webhook"=>"http://requestb.in/11rzly71",
        "confirmations"=>0,
        "status"=>"quote"
      })
    end

    context "validation" do
      it "rejects orders without an in or out amount specified" do
        expect {transfer_api.create_order(in_currency: 'btc', out_currency: 'mxn', out_via: 'atm', webhook: nil, in_amount: nil, out_amount: nil)}.to raise_error("You must specify a value for either in or out")
      end
    end
  end

  context "getting orders" do
    # TODO
    it "allows you to fetch orders you own"

  end

end
