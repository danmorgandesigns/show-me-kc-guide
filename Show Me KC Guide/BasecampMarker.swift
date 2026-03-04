//
//  BasecampMarker.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/22/26.
//

import SwiftUI

struct BasecampMarker: View {
    let flagEmoji: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Text(flagEmoji)
                .font(.system(size: 16))
        }
    }
}

#Preview {
    BasecampMarker(flagEmoji: "🇦🇷")
        .padding()
}
