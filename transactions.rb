# frozen_string_literal: true

class Transaction
  attr_reader :price, :amount
  attr_accessor :fake

  def initialize(price, amount, fake: false)
    @price = price
    @amount = amount
    @fake = fake
  end

  def fake?
    @fake
  end

  def return_percentage(market_price)
    ((market_price.to_f / price.to_f) - 1) * 100
  end
end

class TransactionSet
  attr_reader :transactions, :target_percentages

  def initialize(currency_type)
    @currency_type = currency_type
    @target_percentages = [1.007, 1.017, 1.027, 1.037, 1.047, 1.057]
    @transactions = []
  end

  def add_transaction(price, amount, fake: false)
    transactions.push Transaction.new(price, amount, fake: fake)
  end

  def remove_fakes
    transactions.delete_if {|t| t.fake? }
  end

  def buy_price
    transactions.sum {|t| t.price * t.amount } / transactions.sum(&:amount)
  end

  def return_percentage(market_price)
    (transactions.sum {|t| t.return_percentage(market_price) } / transactions.size).round(2)
  end

  def sell_targets
    target_percentages.map do |p|
      {
        percentage: "#{(p * 100 - 100).round(2)}%",
        price:      average_buy_price * p
      }
    end
  end

  alias_method :sts, :sell_targets
end

ts = TransactionSet.new :AMP
ts.add_transaction 0.03924, 10000
ts.add_transaction 0.03697, 10000

