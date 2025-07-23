import React, {
    useEffect,
    useRef,
    useCallback,
    useState,
    useMemo,
} from "react";
import {
    ScrollView,
    View,
    Text,
    StyleSheet,
    NativeSyntheticEvent,
    NativeScrollEvent,
    Dimensions,
    ActivityIndicator,
} from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { DayCell } from "./DayCell";
import { useCalendar } from "../../contexts/CalendarContext";
import { MonthData } from "../../types/calendar";

const { width } = Dimensions.get("window");
const CELL_SIZE = (width - 24) / 7;
const ROW_HEIGHT = 63;
const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

interface Props {
    onDatePress: (d: Date) => void;
    onYearChange: (y: number) => void;
    onTodayVisibility: (opts: {
        visible: boolean;
        direction: "up" | "down";
    }) => void;
    onCenterOnToday?: (centerFn: () => void) => void;
}

export const CalendarGrid: React.FC<Props> = ({
    onDatePress,
    onYearChange,
    onTodayVisibility,
    onCenterOnToday,
}) => {
    const scrollRef = useRef<ScrollView>(null);
    const hasInitiallyFocused = useRef(false);
    const { monthsData, isLoading, monthRange } = useCalendar();

    /** ---- helpers reused by both mount‑time and Today button ---- */
    const centerOnToday = useCallback(() => {
        if (
            !scrollRef.current ||
            monthsData.length === 0 ||
            !monthsData[0].monthGroups
        )
            return;

        const monthGroups = monthsData[0].monthGroups;
        let rowIndexOfToday = -1;
        let rowCounter = 0;

        for (const monthRows of monthGroups) {
            for (const row of monthRows) {
                if (row.days.some((day) => day.isToday)) {
                    rowIndexOfToday = rowCounter;
                    break;
                }
                rowCounter++;
            }
            if (rowIndexOfToday !== -1) break;
        }

        if (rowIndexOfToday !== -1) {
            const screenHeight = Dimensions.get("window").height;
            const headerHeight = 160; // title + year + weekday row + separator
            const visibleRows = (screenHeight - headerHeight) / ROW_HEIGHT;
            const offset =
                Math.max(
                    0,
                    (rowIndexOfToday - visibleRows / 2 + 0.5) * ROW_HEIGHT
                ) | 0;

            scrollRef.current.scrollTo({ y: offset, animated: true });
        }
    }, [monthsData]);

    /* center when screen gains focus - but only on first focus */
    useFocusEffect(
        useCallback(() => {
            if (!hasInitiallyFocused.current) {
                hasInitiallyFocused.current = true;
                setTimeout(centerOnToday, 100);
            }
        }, [centerOnToday])
    );

    /* pass centerOnToday function to parent */
    useEffect(() => {
        if (onCenterOnToday) {
            onCenterOnToday(centerOnToday);
        }
    }, [centerOnToday, onCenterOnToday]);

    /** ---------- scroll handler: year + today button -------------- */
    const last = useRef({ year: new Date().getFullYear(), btn: false });

    const handleScroll = useCallback(
        (e: NativeSyntheticEvent<NativeScrollEvent>) => {
            if (isLoading || !monthsData[0]?.monthGroups) return;
            
            const y = e.nativeEvent.contentOffset.y;
            const viewport = e.nativeEvent.layoutMeasurement.height;

            const firstVisibleRow = Math.floor(y / ROW_HEIGHT);
            const lastVisibleRow = Math.ceil((y + viewport) / ROW_HEIGHT);

            const groups = monthsData[0].monthGroups;
            let rowCounter = 0;
            let currentYearFound = last.current.year;
            let todayRow = -1;

            const today = new Date();
            const startMonth = new Date(
                today.getFullYear(),
                today.getMonth() + monthRange.start,
                1
            );

            for (let m = 0; m < groups.length; m++) {
                const rows = groups[m];
                const monthDate = new Date(startMonth);
                monthDate.setMonth(startMonth.getMonth() + m);

                // Check if current scroll position is within this month for year detection
                if (
                    firstVisibleRow >= rowCounter &&
                    firstVisibleRow < rowCounter + rows.length
                ) {
                    currentYearFound = monthDate.getFullYear();
                }

                // Find today's row once
                if (todayRow === -1) {
                    for (let i = 0; i < rows.length; i++) {
                        if (rows[i].days.some((d) => d.isToday)) {
                            todayRow = rowCounter + i;
                            break;
                        }
                    }
                }

                rowCounter += rows.length;
            }

            // Update year if changed
            if (currentYearFound !== last.current.year) {
                last.current.year = currentYearFound;
                onYearChange(currentYearFound);
            }

            // Handle today button visibility
            if (todayRow !== -1) {
                const visible = todayRow >= firstVisibleRow && todayRow <= lastVisibleRow;
                
                if (visible !== !last.current.btn) {
                    last.current.btn = !visible;
                    onTodayVisibility({
                        visible: !visible,
                        direction: todayRow < firstVisibleRow ? "up" : "down",
                    });
                }
            }
        },
        [isLoading, monthsData, monthRange, onYearChange, onTodayVisibility]
    );

    /** --------------- build all <DayCell/> rows ------------------- */
    const rowsJSX = useMemo(() => {
        if (isLoading || !monthsData[0]?.monthGroups) return null;
        
        const jsx: React.ReactElement[] = [];
        const today = new Date();
        const startMonth = new Date(
            today.getFullYear(),
            today.getMonth() + monthRange.start,
            1
        );

        let globalRow = 0;

        monthsData[0].monthGroups.forEach((monthRows, monthIdx) => {
            const monthDate = new Date(startMonth);
            monthDate.setMonth(startMonth.getMonth() + monthIdx);
            const abbrev = monthDate.toLocaleDateString("en-US", {
                month: "short",
            });

            monthRows.forEach((row) => {
                // pad row to 7 positions
                const padded: any[] = [...row.days];
                while (padded.length < 7) padded.push(null);

                jsx.push(
                    <View key={`row-${globalRow++}`} style={styles.row}>
                        {padded.map((day, i) =>
                            day ? (
                                <DayCell
                                    key={`${day.date.getTime()}-${i}`}
                                    day={day}
                                    onPress={onDatePress}
                                    monthAbbrev={abbrev}
                                />
                            ) : (
                                <View key={`empty-${i}`} style={styles.empty} />
                            )
                        )}
                    </View>
                );
            });
        });

        return jsx;
    }, [isLoading, monthsData, monthRange, onDatePress]);

    /** ----------------------- render ------------------------------ */
    if (isLoading) {
        return (
            <>
                {/* weekday strip */}
                <View style={styles.weekHeader}>
                    {WEEKDAYS.map((d) => (
                        <View
                            key={d}
                            style={{ width: CELL_SIZE, alignItems: "center" }}
                        >
                            <Text style={styles.weekdayText}>{d}</Text>
                        </View>
                    ))}
                </View>
                <View style={styles.weekHeaderBorder} />
                
                {/* Loading state */}
                <View style={styles.loadingContainer}>
                    <ActivityIndicator size="large" color="#FFFFFF" />
                    <Text style={styles.loadingText}>Loading calendar...</Text>
                </View>
            </>
        );
    }

    return (
        <>
            {/* weekday strip */}
            <View style={styles.weekHeader}>
                {WEEKDAYS.map((d) => (
                    <View
                        key={d}
                        style={{ width: CELL_SIZE, alignItems: "center" }}
                    >
                        <Text style={styles.weekdayText}>{d}</Text>
                    </View>
                ))}
            </View>
            <View style={styles.weekHeaderBorder} />

            <ScrollView
                ref={scrollRef}
                onScroll={handleScroll}
                scrollEventThrottle={200}
                showsVerticalScrollIndicator={false}
                style={{ flex: 1 }}
            >
                <View style={{ paddingHorizontal: 12, paddingTop: 8 }}>
                    {rowsJSX}
                </View>
            </ScrollView>
        </>
    );
};

const styles = StyleSheet.create({
    weekHeader: {
        flexDirection: "row",
        paddingHorizontal: 12,
        paddingVertical: 8,
    },
    weekHeaderBorder: {
        height: 1,
        backgroundColor: "#333",
        marginHorizontal: 12,
    },
    weekdayText: { fontSize: 12, fontWeight: "500", color: "#3a3a3a" },
    row: { flexDirection: "row", marginBottom: 8 },
    empty: { width: CELL_SIZE, height: 55 },
    loadingContainer: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        paddingVertical: 60,
    },
    loadingText: {
        color: "#666666",
        fontSize: 16,
        marginTop: 16,
        fontWeight: "500",
    },
});
