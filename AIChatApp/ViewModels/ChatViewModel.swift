import Foundation
import SwiftData
import Combine
import AVFoundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentSession: Session?
    @Published var isRecording = false
    @Published var inputText = ""
    @Published var isProcessing = false
    @Published var processingSteps: [String] = []
    @Published var isLiveMode: Bool = false
    @Published var sessions: [Session] = []
    @Published var isOffline: Bool = false
    @Published var quickActions: [String] = ["Add Note", "Prep Meeting", "Top Customers", "Create Touchpoint"]

    var modelContext: ModelContext?
    private var speechRecognizer = SpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    private let monitor = NWPathMonitor()
    private var cachedResponses: [String: String] = [:]

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        speechRecognizer.onResult = { [weak self] text in
            self?.inputText = text
        }
        speechRecognizer.onCommand = { [weak self] command in
            self?.performQuickAction(command)
        }
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = path.status != .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func startNewSession(title: String) {
        let newSession = Session(title: title)
        currentSession = newSession
        messages = []
        if let context = modelContext {
            context.insert(newSession)
        }
        saveSession()
    }

    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        let userMessage = Message(text: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        processAIResponse(for: text)
        saveSession()
        // Auto-stop recording after sending voice command
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
        }
    }

    private func processAIResponse(for userInput: String) {
        isProcessing = true
        processingSteps = []
        // Simulate processing steps
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processingSteps.append("Parsing input...")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if userInput.lowercased().contains("note") || userInput.lowercased().contains("touchpoint") {
                self.processingSteps.append("Creating touchpoint...")
            } else if userInput.lowercased().contains("meeting") || userInput.lowercased().contains("prep") {
                self.processingSteps.append("Fetching customer data...")
            } else {
                self.processingSteps.append("Processing request...")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.processingSteps.append("Confirming...")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let aiResponse = self.mockAIResponse(for: userInput)
            let aiMessage = Message(text: aiResponse, isUser: false)
            self.messages.append(aiMessage)
            self.isProcessing = false
            self.processingSteps = []
            if self.isLiveMode {
                self.speakResponse(aiResponse)
            }
            self.saveSession()
        }
    }

    private func mockAIResponse(for input: String) -> String {
        let lowerInput = input.lowercased()
        // Handle specific intents from case study narrative
        if lowerInput.contains("add a note") && lowerInput.contains("customer xyz") {
            // Simulate transcription and confirmation for the specific note
            return "Note added for Customer XYZ: They liked the new shingle promotion and will order next week. Touchpoint created and saved to session."
        } else if lowerInput.contains("what should i know") && lowerInput.contains("customer xyz") {
            // Meeting prep response
            return "Meeting prep for Customer XYZ:\n- Recent orders: 3 units of shingles last month\n- Prior touchpoints: Discussed promotions in previous visit\n- Key notes: Interested in bulk discounts, positive feedback on quality\n- Promotions: 15% off next order, free installation consultation\n- Outstanding items: Follow up on quote for siding upgrade"
        } else if lowerInput.contains("add a note") || lowerInput.contains("touchpoint") || lowerInput.contains("met with") {
            // General note/touchpoint creation
            return "Touchpoint created successfully. Note transcribed and saved."
        } else if lowerInput.contains("heading into a meeting") || lowerInput.contains("meeting prep") {
            return "Meeting preparation summary:\n- Customer history and recent interactions\n- Key stats and opportunities\n- Relevant promotions and notes"
        } else if lowerInput.contains("top 3 customers") || lowerInput.contains("top customers") {
            return "Top 3 customers this month:\n1. ABC Corp - $45,000 in sales\n2. XYZ Ltd - $38,000 in sales\n3. DEF Inc - $32,000 in sales"
        } else if lowerInput.contains("create touchpoint") {
            return "Touchpoint created. Parsed input and confirmed creation."
        } else if lowerInput.contains("note") || lowerInput.contains("add") {
            return "Note added successfully. Touchpoint created for the customer."
        } else if lowerInput.contains("meeting") || lowerInput.contains("prep") {
            return "Meeting preparation summary:\n- Customer history\n- Key stats\n- Relevant promotions"
        } else {
            return "I'm your sales co-pilot. Try saying 'add a note for Customer XYZ' or 'what should I know about Customer ABC before the meeting?'"
        }
    }

    func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording()
        }
        isRecording.toggle()
    }

    func provideFeedback(for message: Message, feedback: Feedback) {
        message.feedback = feedback
        saveSession()
    }

    func saveSession() {
        guard let session = currentSession, let context = modelContext else { return }
        // Ensure messages are sorted by timestamp before saving
        session.messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
        do {
            try context.save()
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    func performQuickAction(_ action: String) {
        sendMessage(action)
    }

    func loadSession(_ session: Session) {
        currentSession = session
        messages = session.messages
    }

    func deleteSession(_ session: Session) {
        guard let context = modelContext else { return }
        context.delete(session)
        do {
            try context.save()
            // Refresh sessions list
            sessions = getAllSessions()
            // If the deleted session was the current one, clear it
            if currentSession?.id == session.id {
                currentSession = nil
                messages = []
            }
        } catch {
            print("Failed to delete session: \(error)")
        }
    }

    func getAllSessions() -> [Session] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            return []
        }
    }

    func loadMostRecentSession() {
        let sessions = getAllSessions()
        if let mostRecent = sessions.first {
            loadSession(mostRecent)
        } else {
            startNewSession(title: "New Session")
        }
    }

    private func speakResponse(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
}
