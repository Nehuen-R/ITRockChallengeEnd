//
//  Error.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import Foundation

enum ErrorLogger: String {
    case notFoundedProducts = "No se encontraron productos"
    case notFoundedProduct = "No se encontro el producto"
    case invalidQR = "QR invalido"
    case badUserOrPassWord = "Usuario o contraseña incorrectos"
    case empty = "Faltan datos ingresados, ingreselos por favor!"
    case badPayment = "Tarjeta inválida checkee los datos ingresados"
}
