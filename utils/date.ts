import { CalendarDay, MonthData } from "../types/calendar";

/** Return true when two Dates share the same Y‑M‑D. */
export const isSameDay = (a: Date, b: Date) =>
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate();

/**
 * Build one `MonthData` object whose `monthGroups` property contains *all*
 * month rows in a continuous grid that spans `monthRange`.
 *
 * The structure mirrors what the original monolithic component produced:
 * ```text
 * MonthData[] length === 1
 *   └─ monthGroups: monthIndex[] → weekRow[] → { days[], isLastInMonth }
 * ```
 */
export const generateMonthsData = (monthRange: {
    start: number;
    end: number;
}): MonthData[] => {
    const today = new Date();

    const monthGroups: {
        days: CalendarDay[];
        isLastInMonth: boolean;
    }[][] = [];

    // e.g. start = -12 (1 yr back), end = 24 (2 yrs forward)
    const startMonth = new Date(
        today.getFullYear(),
        today.getMonth() + monthRange.start,
        1
    );
    const totalMonths = monthRange.end - monthRange.start;

    for (let offset = 0; offset < totalMonths; offset++) {
        const monthDate = new Date(startMonth);
        monthDate.setMonth(startMonth.getMonth() + offset);

        const firstDayOfMonth = new Date(
            monthDate.getFullYear(),
            monthDate.getMonth(),
            1
        );
        const lastDayOfMonth = new Date(
            monthDate.getFullYear(),
            monthDate.getMonth() + 1,
            0
        );

        const nextMonth =
            offset < totalMonths - 1
                ? new Date(
                      startMonth.getFullYear(),
                      startMonth.getMonth() + offset + 1,
                      1
                  )
                : null;

        /* ---------------- build the flat list of CalendarDay objects ------------- */
        const monthDays: CalendarDay[] = [];

        // real days of this month
        for (let d = 1; d <= lastDayOfMonth.getDate(); d++) {
            const cur = new Date(
                monthDate.getFullYear(),
                monthDate.getMonth(),
                d
            );

            // if we *do* have a next month, skip the tail‑end days that would
            // appear in the first calendar row of that next month
            if (nextMonth) {
                const nextMonthWeekStart = new Date(nextMonth);
                nextMonthWeekStart.setDate(
                    nextMonth.getDate() - nextMonth.getDay()
                );

                const isInNextFirstWeek =
                    cur >= nextMonthWeekStart && cur < nextMonth;
                if (isInNextFirstWeek) continue;
            }

            monthDays.push({
                date: cur,
                isToday: isSameDay(cur, today),
                isCurrentMonth:
                    cur.getMonth() === today.getMonth() &&
                    cur.getFullYear() === today.getFullYear(),
                hasWorkout: false, // ← replace later with real data
            });
        }

        // leading padding cells taken from previous month to fill first row
        if (firstDayOfMonth.getDay() > 0) {
            for (let i = firstDayOfMonth.getDay() - 1; i >= 0; i--) {
                const prev = new Date(firstDayOfMonth);
                prev.setDate(firstDayOfMonth.getDate() - (i + 1));

                monthDays.unshift({
                    date: prev,
                    isToday: isSameDay(prev, today),
                    isCurrentMonth:
                        prev.getMonth() === today.getMonth() &&
                        prev.getFullYear() === today.getFullYear(),
                    hasWorkout: false,
                });
            }
        }

        /* ------------- split into week rows (length = 7 each) ------------------- */
        const rows: { days: CalendarDay[]; isLastInMonth: boolean }[] = [];
        for (let i = 0; i < monthDays.length; i += 7) {
            const week = monthDays.slice(i, i + 7);

            // pad trailing nulls for incomplete final week
            while (week.length < 7) week.push(null as any);

            const isLastWeek = i + 7 >= monthDays.length;
            rows.push({
                days: week.filter(Boolean) as CalendarDay[],
                isLastInMonth: isLastWeek,
            });
        }
        monthGroups.push(rows);
    }

    // Return single MonthData wrapper that holds the master grid.
    return [{ monthDate: today, days: [], monthGroups }];
};
