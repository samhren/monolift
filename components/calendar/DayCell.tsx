import React from "react";
import {
    TouchableOpacity,
    View,
    Text,
    StyleSheet,
    Dimensions,
} from "react-native";
import { CalendarDay } from "../../types/calendar";

interface Props {
    day: CalendarDay | null;
    onPress: (d: Date) => void;
    monthAbbrev?: string; // needed for 1st‑of‑month label
}

export const DayCell: React.FC<Props> = ({ day, onPress, monthAbbrev }) => {
    if (!day) return <View style={styles.empty} />;

    const isFirstOfMonth = day.date.getDate() === 1;

    return (
        <TouchableOpacity
            style={styles.frame}
            onPress={() => {
                const startTime = performance.now();
                console.log(`[${startTime.toFixed(2)}ms] DayCell pressed:`, day.date);
                onPress(day.date);
                const endTime = performance.now();
                console.log(`[${endTime.toFixed(2)}ms] DayCell onPress callback finished (took ${(endTime - startTime).toFixed(2)}ms)`);
            }}
        >
            {isFirstOfMonth && (
                <Text style={styles.monthLabel}>{monthAbbrev}</Text>
            )}
            <View
                style={[
                    styles.circle,
                    day.hasWorkout && styles.workout,
                    day.isToday && !day.hasWorkout && styles.today,
                ]}
            >
                <Text
                    style={[
                        styles.date,
                        !isFirstOfMonth && styles.otherMonthDate,
                        (day.hasWorkout || day.isToday) && styles.selectedDate,
                    ]}
                >
                    {day.date.getDate()}
                </Text>
            </View>
        </TouchableOpacity>
    );
};

const { width } = Dimensions.get("window");
const CELL_SIZE = (width - 24) / 7;

const styles = StyleSheet.create({
    frame: {
        width: CELL_SIZE,
        height: 55,
        justifyContent: "flex-end",
        alignItems: "center",
        paddingBottom: 4,
    },
    empty: { width: CELL_SIZE, height: 55 },
    monthLabel: {
        fontSize: 12,
        fontWeight: "700",
        color: "#fff",
        position: "absolute",
        top: 1,
    },
    circle: {
        width: 36,
        height: 36,
        borderRadius: 18,
        justifyContent: "center",
        alignItems: "center",
    },
    workout: { backgroundColor: "#3a3a3a" },
    today: { backgroundColor: "rgba(58,58,58,0.5)" },
    date: { fontSize: 20, fontWeight: "600", color: "#fff" },
    otherMonthDate: { color: "#919191" },
    selectedDate: { fontWeight: "600" },
});
