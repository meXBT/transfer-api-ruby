# Mexbt Transfer API Ruby client

This is a lightweight ruby client for the [meXBT](https://mexbt.com) Transfer API. It doesn't try and do anything clever with the JSON response from the API, it simply
returns it as-is.

## Install

If using bundler simply this to your Gemfile:

    gem 'mexbt-transfer-api'

And run `bundle install` of course.

## Ruby version

You need to be using Ruby 2.1 or higher.


## Setting up a client

    api = Mexbt::TransferApi.new("your-api-key", "your-api-key", your_client_id)

If you want to work against another endpoint, you can configure that like:

    api = Mexbt::TransferApi.new("your-api-key", "your-api-key", your_client_id, endpoint: "https://transfer-staging.mexbt.com/v1")

## Checking api is up and you can authenticate ok

    api.ping()

## Creating orders

    api.create_order(in_currency: 'btc', out_currency: 'mxn', out_via: 'atm', out_amount: 100, webhook: 'http://your.domain/hook')

## Fetching an order

    api.get_order(1)
