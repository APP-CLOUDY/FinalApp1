//  User.swift
import Foundation

struct User: Codable {
    let id: UUID
    var first_name: String
    var email: String
    var role: String
    var date_of_birth: String
}
