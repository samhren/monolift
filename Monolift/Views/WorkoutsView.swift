import SwiftUI
import CoreData

struct WorkoutsView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutTemplate.name, ascending: true)],
        animation: .default
    ) private var templates: FetchedResults<WorkoutTemplate>
    
    @State private var showingAddTemplate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if templates.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dumbbell")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#3a3a3a"))
                        
                        Text("No Workout Templates")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Create your first workout template to get started")
                            .font(.body)
                            .foregroundColor(Color(hex: "#3a3a3a"))
                            .multilineTextAlignment(.center)
                        
                        Button("Create Template") {
                            showingAddTemplate = true
                        }
                        .buttonStyle(MonoliftButtonStyle())
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(templates) { template in
                                WorkoutTemplateCard(template: template)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTemplate = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTemplate) {
            AddTemplateView()
        }
    }
}

struct WorkoutTemplateCard: View {
    let template: WorkoutTemplate
    @State private var isPressed = false
    
    var body: some View {
        Button {
            // Start workout action
            startWorkout()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name ?? "Unnamed Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("\(template.exercises?.count ?? 0) exercises")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#3a3a3a"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                if template.daysPerWeek > 0 {
                    Text("\(template.daysPerWeek) days per week")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#3a3a3a"))
                }
            }
            .padding()
            .background(Color(hex: "#3a3a3a"))
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {
            
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
    
    private func startWorkout() {
        // Create new workout session
        let session = WorkoutSession(context: CoreDataManager.shared.context)
        session.id = UUID()
        session.template = template
        session.startedAt = Date()
        session.createdAt = Date()
        session.updatedAt = Date()
        
        CoreDataManager.shared.save()
        
        // TODO: Navigate to workout session view
        print("Started workout: \(template.name ?? "Unnamed")")
    }
}

struct AddTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var templateName = ""
    @State private var daysPerWeek: Int = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Template Name")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        TextField("Enter workout name", text: $templateName)
                            .textFieldStyle(MonoliftTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Days Per Week")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Picker("Days", selection: $daysPerWeek) {
                            ForEach(1...7, id: \.self) { day in
                                Text("\(day)")
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .foregroundColor(.white)
                    .disabled(templateName.isEmpty)
                }
            }
        }
    }
    
    private func saveTemplate() {
        let template = WorkoutTemplate(context: CoreDataManager.shared.context)
        template.id = UUID()
        template.name = templateName
        template.daysPerWeek = Int16(daysPerWeek)
        template.createdAt = Date()
        template.updatedAt = Date()
        
        CoreDataManager.shared.save()
        dismiss()
    }
}

// MARK: - Custom Styles

struct MonoliftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.white : Color(hex: "#3a3a3a"))
            .foregroundColor(configuration.isPressed ? .black : .white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MonoliftTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "#3a3a3a"))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WorkoutsView()
}