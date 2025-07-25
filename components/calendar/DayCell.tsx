import React, { useEffect, useRef } from "react";
import {
    TouchableOpacity,
    View,
    Text,
    StyleSheet,
    Dimensions,
    Animated,
} from "react-native";
import { CalendarDay } from "../../types/calendar";

interface Props {
    day: CalendarDay | null;
    onPress: (d: Date) => void;
    monthAbbrev?: string; // needed for 1st‑of‑month label
    selectedDate?: Date | null;
    isBottomSheetOpen?: boolean;
}

const DayCellComponent: React.FC<Props> = ({
    day,
    onPress,
    monthAbbrev,
    selectedDate,
    isBottomSheetOpen,
}) => {
    if (!day) return <View style={styles.empty} />;

    const isFirstOfMonth = day.date.getDate() === 1;
    const isSelected = Boolean(
        selectedDate &&
        day.date.getTime() === selectedDate.getTime() &&
        isBottomSheetOpen
    );

    const borderOpacity = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        if (isSelected) {
            Animated.timing(borderOpacity, {
                toValue: 1,
                duration: 100,
                useNativeDriver: true,
            }).start();
        } else {
            Animated.timing(borderOpacity, {
                toValue: 0,
                duration: 100,
                useNativeDriver: true,
            }).start();
        }
    }, [isSelected, borderOpacity]);

    return (
        <TouchableOpacity
            style={styles.frame}
            onPress={() => onPress(day.date)}
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
                {isSelected && (
                    <Animated.View
                        style={[
                            StyleSheet.absoluteFill,
                            {
                                borderWidth: 2,
                                borderColor: "#FFFFFF",
                                borderRadius: 8,
                                opacity: borderOpacity,
                            },
                        ]}
                    />
                )}
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

// Memoize the component to prevent unnecessary rerenders
export const DayCell = React.memo(DayCellComponent, (prevProps, nextProps) => {
    // Custom comparison function for better performance
    if (prevProps.monthAbbrev !== nextProps.monthAbbrev) return false;

    // Handle null cases
    if (!prevProps.day && !nextProps.day) return true;
    if (!prevProps.day || !nextProps.day) return false;

    // Compare day properties that affect rendering
    return (
        prevProps.day.date.getTime() === nextProps.day.date.getTime() &&
        prevProps.day.isToday === nextProps.day.isToday &&
        prevProps.day.hasWorkout === nextProps.day.hasWorkout &&
        prevProps.day.isCurrentMonth === nextProps.day.isCurrentMonth &&
        prevProps.selectedDate?.getTime() ===
            nextProps.selectedDate?.getTime() &&
        prevProps.isBottomSheetOpen === nextProps.isBottomSheetOpen
    );
});

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
        borderRadius: 8,
        justifyContent: "center",
        alignItems: "center",
    },
    workout: { backgroundColor: "#3a3a3a" },
    today: { backgroundColor: "rgba(58,58,58,0.5)" },
    date: { fontSize: 20, fontWeight: "600", color: "#fff" },
    otherMonthDate: { color: "#919191" },
    selectedDate: { fontWeight: "600" },
});
