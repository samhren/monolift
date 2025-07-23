export interface CalendarDay {
    date: Date;
    isToday: boolean;
    isCurrentMonth: boolean;
    hasWorkout: boolean;
}

export interface MonthData {
    monthDate: Date;
    days: CalendarDay[];
    monthGroups?: { days: CalendarDay[]; isLastInMonth: boolean }[][];
}
