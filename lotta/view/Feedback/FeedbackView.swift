//
//  FeedbackView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 31/10/2024.
//

import SwiftUI
import Sentry

let FEEDBACK_ENDPOINT = "https://cockpit.intern.lotta.schule/api/feedback"

struct FeedbackView: View {
    @Environment(ModelData.self) var modelData
    private let theme = Theme()

    var name: String
    var email: String
    var onDismiss: (() -> Void)
    
    @State var isLoading = false
    @State var errorMessage: String? = nil
    @State var isShowMessage = false
    @State var comment = ""
    
    var body: some View {
        return NavigationStack {
            Form {
                Text("Wir freuen uns sehr über jegliches Feedback. Änderungswünsche, Fehlermeldungen, Anregungen, Ideen, etc. sind willkommen.")
                    .font(.footnote)
                
                TextField("Kommentar:", text: $comment, axis: .vertical)
                    .disabled(isLoading)
                
            }
            VStack(alignment: .trailing) {
                LottaButton(
                    "senden",
                    action: {
                        let feedback =
                            UserFeedback(
                                feedback: UserFeedbackData(
                                    tenant_id: Int(modelData.currentSession?.tenant.id ?? ""),
                                    title: "iOS App Feedback",
                                    message: comment,
                                    email: email,
                                    name: name
                                )
                            )
                        
                        let jsonEncoder = JSONEncoder()
                        var request = URLRequest(url: URL(string: FEEDBACK_ENDPOINT)!)
                        request.httpMethod = "POST"
                        let body = try! jsonEncoder.encode(feedback)
                        request.httpBody = body
                        request.timeoutInterval = 30
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.addValue("application/json", forHTTPHeaderField: "Accept")
                        Task {
                            do {
                                isLoading = true
                                let (data, response) = try await URLSession.shared.data(for: request)
                                DispatchQueue.main.async {
                                    guard let response = response as? HTTPURLResponse else {
                                        self.errorMessage = "Unbekannter Fehler. Keine Antwort"
                                        return
                                    }
                                    if response.statusCode >= 400 {
                                        self.errorMessage = (try? JSONDecoder().decode(String.self, from: data)) ?? "Unbekannter Fehler"
                                        return
                                    }
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    print(error.localizedDescription)
                                    errorMessage = error.localizedDescription
                                }
                            }
                            self.isShowMessage = true
                        }
                        
                    },
                    isLoading: isLoading
                )
            }
            .padding(.bottom)
            .navigationBarTitle("Feedback")
        }
        .alert(isPresented: $isShowMessage) {
            if let errorMessage = errorMessage {
                Alert(
                    title: Text("Es ist ein Fehler aufgetreten"),
                    message: Text(errorMessage)
                )
            } else {
                Alert(
                    title: Text("Danke"),
                    message: Text("Vielen Dank dafür, dass du dir diese Minuten Zeit genommen hast!")
                )
            }
        }
        .onChange(of: isShowMessage) { oldValue, newValue in
            if (newValue) {
                isLoading = false
            } else if (oldValue && !newValue) {
                self.errorMessage = nil
                onDismiss()
            }
        }
    }
}

struct UserFeedbackData : Codable {
    var tenant_id: Int?
    var title: String
    var message: String
    var email: String
    var name: String
}
struct UserFeedback : Codable {
    let feedback: UserFeedbackData
}

#Preview {
    FeedbackView(name: "Souris", email: "Risquetout", onDismiss: {})
}
