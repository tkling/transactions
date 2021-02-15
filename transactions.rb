# frozen_string_literal: true

class Transaction
  attr_reader :price, :amount
  attr_accessor :fake

  def initialize(price:, amount:, fake: false)
    @price = price
    @amount = amount
    @fake = fake
  end

  class << self
    def from_hash(hash)
      new(**hash.slice(:price, :amount, :fake))
    end
  end

  def fake?
    @fake
  end

  def return_percentage(market_price)
    ((market_price.to_f / price.to_f) - 1) * 100
  end

  def to_h
    { price:  price, amount: amount, fake: fake }
  end
end

TARGET_PERCENTAGES = [1.007, 1.017, 1.027, 1.037, 1.047, 1.057].freeze

class TransactionSet
  attr_reader :currency_type, :transactions

  def initialize(currency_type)
    @currency_type = currency_type
    @transactions = []
  end

  class << self
    def from_hash(hash)
      currency_type = hash.fetch(:currency_type, :not_specified).to_sym
      transactions =  hash.fetch(:transactions, [])

      new(currency_type).tap do |ts|
        transactions.each do |t|
          ts.add_transaction(**t.slice(:price, :amount, :fake))
        end
      end
    end
  end

  def add_transaction(price:, amount:, fake: false)
    transactions.push Transaction.new(price: price, amount: amount, fake: fake)
  end

  def remove_fakes
    transactions.delete_if &:fake?
  end

  def buy_price
    total_spent / total_quantity
  end

  def return_percentage(market_price)
    "#{(transactions.sum {|t| t.return_percentage(market_price) } / transactions.size).round(2)}%"
  end

  def sell_targets
    TARGET_PERCENTAGES.map do |p|
      p_str = "#{(p * 100 - 100).round(2)}%"
      price = (buy_price * p).round(2)
      { p_str => price }
    end
  end

  def total_spent
    transactions.sum {|t| t.price * t.amount }
  end

  def total_quantity
    transactions.sum(&:amount)
  end

  def to_h
    { currency_type: currency_type, transactions:  transactions.map(&:to_h) }
  end

  alias_method :sts, :sell_targets
  alias_method :tq,  :total_quantity
  alias_method :ts,  :total_spent
end
