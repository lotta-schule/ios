//
//  FeedbackView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 31/10/2024.
//

import SwiftUI
import Sentry

struct FeedbackView: View {
    private let theme = Theme()
    
    var name: String
    var email: String
    var onDismiss: (() -> Void)
    
    @State var isShowThankYou: Bool = false
    @State var comment = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Wir freuen uns sehr über jegliches Feedback. Änderungswünsche, Fehlermeldungen, Anregungen, Ideen, etc. sind willkommen.")
                    .font(.footnote)
                
                TextField("Kommentar:", text: $comment, axis: .vertical)
                
            }
            VStack(alignment: .trailing) {
                LottaButton(
                    "senden",
                    action: {
                        let eventId = SentrySDK.capture(message: "User Feedback")
                        let userFeedback = UserFeedback(eventId: eventId)
                        userFeedback.comments = comment
                        SentrySDK.capture(userFeedback: userFeedback)
                        
                        isShowThankYou = true
                        
                    })
            }
            .padding(.bottom)
            .navigationBarTitle("Feedback")
        }
        .alert( isPresented: $isShowThankYou) {
            Alert(
                title: Text("Danke"),
                message: Text("Vielen Dank dafür, dass du dir diese Minuten Zeit genommen hast!")
            )
        }
        .onChange(of: isShowThankYou) { oldValue, newValue in
            if (oldValue && !newValue) {
                onDismiss()
            }
        }
    }
}

#Preview {
    FeedbackView(name: "Souris", email: "Risquetout", onDismiss: {})
}
