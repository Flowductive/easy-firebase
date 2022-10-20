//
//  Price.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/20/22.
//

import EasyFirebase

class Price: FieldObject {
  
  @Field var amount: Float = 0.0
  @Field var currency: Currency = Currency.usd
  
  init(_ amount: Float, currency: Currency = .usd) {
    self.amount = amount
    self.currency = currency
    super.init()
  }
  
  convenience init(_ amount: Int, currency: Currency = .usd) {
    self.init(Float(amount), currency: currency)
  }
  
  required init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }
  
  enum Currency: String, Codable, CaseIterable {
    case usd = "USD", eur = "EUR"
  }
}

class TestPrice: Price {
  
  @Field var test: Int = 1
}
