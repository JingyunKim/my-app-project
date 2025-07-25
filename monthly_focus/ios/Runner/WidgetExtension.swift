import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), goals: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), goals: loadGoals())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let goals = loadGoals()
        let entry = SimpleEntry(date: Date(), goals: goals)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func loadGoals() -> [Goal] {
        // UserDefaults에서 목표 데이터 로드
        let userDefaults = UserDefaults(suiteName: "group.com.example.monthlyfocus")
        guard let data = userDefaults?.data(forKey: "monthlyGoals") else { return [] }
        
        do {
            let goals = try JSONDecoder().decode([Goal].self, from: data)
            return goals.filter { goal in
                let now = Date()
                let goalDate = Calendar.current.date(from: DateComponents(year: goal.year, month: goal.month)) ?? now
                return Calendar.current.isDate(goalDate, equalTo: now, toGranularity: .month)
            }
        } catch {
            print("목표 데이터 로드 실패: \(error)")
            return []
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let goals: [Goal]
}

struct Goal: Codable {
    let id: String
    let title: String
    let isCompleted: Bool
    let year: Int
    let month: Int
}

struct MonthlyFocusWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("오늘의 목표")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if entry.goals.isEmpty {
                Text("목표가 설정되지 않았습니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(entry.goals.prefix(4), id: \.id) { goal in
                    HStack {
                        Button(action: {
                            toggleGoal(goal)
                        }) {
                            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(goal.isCompleted ? .green : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(goal.title)
                            .font(.caption)
                            .lineLimit(2)
                            .strikethrough(goal.isCompleted)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    
    private func toggleGoal(_ goal: Goal) {
        // 목표 체크 상태 토글
        let userDefaults = UserDefaults(suiteName: "group.com.example.monthlyfocus")
        guard let data = userDefaults?.data(forKey: "monthlyGoals") else { return }
        
        do {
            var goals = try JSONDecoder().decode([Goal].self, from: data)
            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = Goal(
                    id: goal.id,
                    title: goal.title,
                    isCompleted: !goal.isCompleted,
                    year: goal.year,
                    month: goal.month
                )
                
                let updatedData = try JSONEncoder().encode(goals)
                userDefaults?.set(updatedData, forKey: "monthlyGoals")
                
                // 위젯 새로고침
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("목표 업데이트 실패: \(error)")
        }
    }
}

@main
struct MonthlyFocusWidget: Widget {
    let kind: String = "MonthlyFocusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MonthlyFocusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("월간 집중")
        .description("오늘의 목표를 확인하고 체크할 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MonthlyFocusWidget_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyFocusWidgetEntryView(entry: SimpleEntry(date: Date(), goals: [
            Goal(id: "1", title: "운동하기", isCompleted: false, year: 2024, month: 1),
            Goal(id: "2", title: "책 읽기", isCompleted: true, year: 2024, month: 1),
            Goal(id: "3", title: "공부하기", isCompleted: false, year: 2024, month: 1),
            Goal(id: "4", title: "명상하기", isCompleted: false, year: 2024, month: 1)
        ]))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
} 