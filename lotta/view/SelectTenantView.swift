//
//  SelectTenantView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct SelectTenantView: View {
    var onSelect: (Tenant) -> Void
    @State var tenants = [
        Tenant(id: "1", title: "Lotta Infos & Hilfe", slug: "info"),
        Tenant(id: "2", title: "Christian-Gottfried-Ehrenberg-Gymnasium", slug: "ehrenberg")
    ]
    var body: some View {
        VStack {
            Image("LottaLogo")
                .resizable()
                .frame(width: 100, height: 100) // Adjust the size as needed
                .padding(.top, 50)
                .padding(.bottom, 75)
            
            Text("Wähle deine Schule.")
            
            List {
                ForEach(self.tenants, id: \.id) { tenant in
                    Text(tenant.title)
                        .onTapGesture {
                            withAnimation {
                                onSelect(tenant)
                            }
                        }
                }
            }
            .listStyle(.inset)
            .frame(maxWidth: 400)
            .padding()
            
            Text(try! AttributedString(
                markdown: "Besuche [lotta.schule](https://lotta.schule) und teste Lotta kostenlos aus!"
            ))
            .padding(50)
            .multilineTextAlignment(.center)
        }
    }
    
}

#Preview {
    SelectTenantView(onSelect: { tenant in print(tenant)} )
        // .modelContainer(for: Item.self, inMemory: true)
}
