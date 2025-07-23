import SwiftUI
import Charts
import CoreData

struct ProgressView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default
    ) private var exercises: FetchedResults<Exercise>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseSet.session?.startedAt, ascending: false)],
        animation: .default
    ) private var sets: FetchedResults<ExerciseSet>
    
    @State private var selectedExercise: Exercise?
    @State private var timeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "1W"
        case month = "1M"
        case threeMonths = "3M"
        case year = "1Y"
        
        var title: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .threeMonths: return "3 Months"
            case .year: return "Year"
            }
        }
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time Range Picker
                        timeRangePicker
                        
                        // Exercise Selector
                        exerciseSelector
                        
                        if let selectedExercise = selectedExercise {
                            // 1RM Progress Chart
                            oneRMChartView(for: selectedExercise)
                            
                            // Weekly Volume Chart
                            weeklyVolumeChartView(for: selectedExercise)
                            
                            // Stats Summary
                            statsView(for: selectedExercise)
                        } else {
                            // Overall Progress
                            overallStatsView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if selectedExercise == nil && !exercises.isEmpty {
                selectedExercise = exercises.first
            }
        }
    }
    
    private var timeRangePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time Range")
                .font(.headline)
                .foregroundColor(.white)
            
            Picker("Time Range", selection: $timeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.title)
                        .tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var exerciseSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise")
                .font(.headline)
                .foregroundColor(.white)
            
            if exercises.isEmpty {
                Text("No exercises found")
                    .foregroundColor(Color(hex: "#3a3a3a"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#3a3a3a").opacity(0.3))
                    .cornerRadius(8)
            } else {
                Picker("Exercise", selection: $selectedExercise) {
                    ForEach(exercises, id: \.self) { exercise in
                        Text(exercise.name ?? "Unknown")
                            .tag(exercise as Exercise?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.white)
                .padding()
                .background(Color(hex: "#3a3a3a"))
                .cornerRadius(8)
            }
        }
    }
    
    private func oneRMChartView(for exercise: Exercise) -> some View {
        let data = oneRMData(for: exercise)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("1RM Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            if data.isEmpty {
                Text("No data available")
                    .foregroundColor(Color(hex: "#3a3a3a"))
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("1RM", point.oneRM)
                    )
                    .foregroundStyle(.white)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("1RM", point.oneRM)
                    )
                    .foregroundStyle(.white)
                }
                .frame(height: 200)
                .chartBackground { chartProxy in
                    Color(hex: "#3a3a3a")
                        .opacity(0.3)
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(Color.clear)
                }
            }
        }
        .padding()
        .background(Color(hex: "#3a3a3a").opacity(0.3))
        .cornerRadius(12)
    }
    
    private func weeklyVolumeChartView(for exercise: Exercise) -> some View {
        let data = weeklyVolumeData(for: exercise)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Volume")
                .font(.headline)
                .foregroundColor(.white)
            
            if data.isEmpty {
                Text("No data available")
                    .foregroundColor(Color(hex: "#3a3a3a"))
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(data) { point in
                    BarMark(
                        x: .value("Week", point.week),
                        y: .value("Volume", point.volume)
                    )
                    .foregroundStyle(.white)
                }
                .frame(height: 200)
                .chartBackground { chartProxy in
                    Color(hex: "#3a3a3a")
                        .opacity(0.3)
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(Color.clear)
                }
            }
        }
        .padding()
        .background(Color(hex: "#3a3a3a").opacity(0.3))
        .cornerRadius(12)
    }
    
    private func statsView(for exercise: Exercise) -> some View {
        let exerciseSets = sets.filter { $0.exercise == exercise }
        let bestSet = exerciseSets.max { (set1, set2) in
            calculateOneRM(reps: Int(set1.reps), load: set1.load) < calculateOneRM(reps: Int(set2.reps), load: set2.load)
        }
        
        let totalVolume = exerciseSets.reduce(0.0) { result, set in
            result + (Double(set.reps) * set.load)
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                StatCard(title: "Best 1RM", value: bestSet != nil ? "\(Int(calculateOneRM(reps: Int(bestSet!.reps), load: bestSet!.load))) lbs" : "N/A")
                StatCard(title: "Total Volume", value: "\(Int(totalVolume)) lbs")
            }
            
            HStack {
                StatCard(title: "Total Sets", value: "\(exerciseSets.count)")
                StatCard(title: "Avg Reps", value: exerciseSets.isEmpty ? "N/A" : "\(Int(exerciseSets.map { Double($0.reps) }.reduce(0, +) / Double(exerciseSets.count)))")
            }
        }
        .padding()
        .background(Color(hex: "#3a3a3a").opacity(0.3))
        .cornerRadius(12)
    }
    
    private var overallStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                StatCard(title: "Total Workouts", value: "\(totalWorkouts)")
                StatCard(title: "This Week", value: "\(workoutsThisWeek)")
            }
            
            HStack {
                StatCard(title: "Total Sets", value: "\(sets.count)")
                StatCard(title: "Total Volume", value: "\(Int(totalVolume)) lbs")
            }
        }
        .padding()
        .background(Color(hex: "#3a3a3a").opacity(0.3))
        .cornerRadius(12)
    }
    
    // MARK: - Data Calculations
    
    private func oneRMData(for exercise: Exercise) -> [OneRMDataPoint] {
        let exerciseSets = sets.filter { $0.exercise == exercise }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        
        let recentSets = exerciseSets.filter { set in
            guard let sessionDate = set.session?.startedAt else { return false }
            return sessionDate >= cutoffDate
        }
        
        // Group by date and find best set for each day
        let groupedByDate = Dictionary(grouping: recentSets) { set in
            guard let sessionDate = set.session?.startedAt else { return Date() }
            return Calendar.current.startOfDay(for: sessionDate)
        }
        
        return groupedByDate.compactMap { (date, sets) in
            guard let bestSet = sets.max(by: { calculateOneRM(reps: Int($0.reps), load: $0.load) < calculateOneRM(reps: Int($1.reps), load: $1.load) }) else {
                return nil
            }
            
            return OneRMDataPoint(
                date: date,
                oneRM: calculateOneRM(reps: Int(bestSet.reps), load: bestSet.load)
            )
        }.sorted { $0.date < $1.date }
    }
    
    private func weeklyVolumeData(for exercise: Exercise) -> [WeeklyVolumeDataPoint] {
        let exerciseSets = sets.filter { $0.exercise == exercise }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        
        let recentSets = exerciseSets.filter { set in
            guard let sessionDate = set.session?.startedAt else { return false }
            return sessionDate >= cutoffDate
        }
        
        // Group by week
        let groupedByWeek = Dictionary(grouping: recentSets) { set in
            guard let sessionDate = set.session?.startedAt else { return Date() }
            return Calendar.current.dateInterval(of: .weekOfYear, for: sessionDate)?.start ?? Date()
        }
        
        return groupedByWeek.map { (weekStart, sets) in
            let volume = sets.reduce(0.0) { result, set in
                result + (Double(set.reps) * set.load)
            }
            
            return WeeklyVolumeDataPoint(
                week: weekStart,
                volume: volume
            )
        }.sorted { $0.week < $1.week }
    }
    
    private func calculateOneRM(reps: Int, load: Double) -> Double {
        guard reps > 0 && reps <= 10 else { return load }
        return load * (1 + Double(reps) / 30.0)
    }
    
    private var totalWorkouts: Int {
        let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }
    
    private var workoutsThisWeek: Int {
        let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        request.predicate = NSPredicate(format: "startedAt >= %@", weekStart as NSDate)
        return (try? context.count(for: request)) ?? 0
    }
    
    private var totalVolume: Double {
        sets.reduce(0.0) { result, set in
            result + (Double(set.reps) * set.load)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color(hex: "#3a3a3a"))
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "#3a3a3a"))
        .cornerRadius(8)
    }
}

struct OneRMDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let oneRM: Double
}

struct WeeklyVolumeDataPoint: Identifiable {
    let id = UUID()
    let week: Date
    let volume: Double
}

#Preview {
    ProgressView()
}