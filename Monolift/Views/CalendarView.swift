import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutSession.startedAt, ascending: false)],
        animation: .default
    ) private var sessions: FetchedResults<WorkoutSession>
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Calendar Header
                    MonthHeaderView(currentMonth: $currentMonth)
                    
                    // Calendar Grid
                    CalendarGridView(
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        workoutDates: workoutDates
                    )
                    
                    Spacer()
                    
                    // Selected Date Details
                    if let sessionForDate = sessionForSelectedDate {
                        WorkoutSessionDetailView(session: sessionForDate)
                    } else {
                        Text("No workout on \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundColor(Color(hex: "#3a3a3a"))
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var workoutDates: Set<String> {
        Set(sessions.compactMap { session in
            guard let startDate = session.startedAt else { return nil }
            return Calendar.current.dateInterval(of: .day, for: startDate)?.start.formatted(date: .abbreviated, time: .omitted)
        })
    }
    
    private var sessionForSelectedDate: WorkoutSession? {
        sessions.first { session in
            guard let startDate = session.startedAt else { return false }
            return Calendar.current.isDate(startDate, inSameDayAs: selectedDate)
        }
    }
}

struct MonthHeaderView: View {
    @Binding var currentMonth: Date
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            
            Spacer()
            
            Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
        .padding()
    }
}

struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let workoutDates: Set<String>
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#3a3a3a"))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            hasWorkout: workoutDates.contains(date.formatted(date: .abbreviated, time: .omitted))
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding()
        }
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        // Find the first day of the week that contains the first day of the month
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: monthStart)!
        
        var days: [Date?] = []
        var current = startDate
        
        while current < monthEnd {
            if calendar.dateInterval(of: .month, for: current)?.contains(monthStart) == true {
                days.append(current)
            } else {
                days.append(nil)
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        // Pad to full weeks
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasWorkout: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white : Color.clear)
                    .frame(width: 36, height: 36)
                
                if hasWorkout && !isSelected {
                    Circle()
                        .fill(Color(hex: "#3a3a3a"))
                        .frame(width: 36, height: 36)
                }
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(hasWorkout ? .semibold : .regular)
                    .foregroundColor(
                        isSelected ? .black :
                        hasWorkout ? .white :
                        isCurrentMonth ? .white : Color(hex: "#3a3a3a")
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 40)
    }
}

struct WorkoutSessionDetailView: View {
    let session: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Workout Session")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let startTime = session.startedAt {
                    Text(startTime.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(Color(hex: "#3a3a3a"))
                }
            }
            
            if let templateName = session.template?.name {
                Text("Template: \(templateName)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#3a3a3a"))
            }
            
            if let setsCount = session.sets?.count, setsCount > 0 {
                Text("\(setsCount) sets completed")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#3a3a3a"))
            }
        }
        .padding()
        .background(Color(hex: "#3a3a3a"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    CalendarView()
}