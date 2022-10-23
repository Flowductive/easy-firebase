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
  
  convenience init(_ amount: Float, currency: Currency = .usd) {
    self.init()
    self.amount = amount
    self.currency = currency
  }

  convenience init(_ amount: Int, currency: Currency = .usd) {
    self.init(Float(amount), currency: currency)
  }
  
  enum Currency: String, Codable, CaseIterable {
    case usd = "USD", eur = "EUR"
  }
}
