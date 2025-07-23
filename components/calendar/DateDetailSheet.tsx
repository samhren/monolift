import React, { memo } from "react";
import { View, Text, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";

interface Props {
    date: Date | null;
}

export const DateDetailSheet: React.FC<Props> = memo(({ date }) => {
    const renderStartTime = performance.now();
    console.log(`[${renderStartTime.toFixed(2)}ms] DateDetailSheet rendering with date:`, date);
    if (!date) {
        console.log(`[${performance.now().toFixed(2)}ms] DateDetailSheet returning null (no date)`);
        return null;
    }
    const formatted = date.toLocaleDateString("en-US", {
        weekday: "long",
        month: "long",
        day: "numeric",
        year: "numeric",
    });
    const renderEndTime = performance.now();
    console.log(`[${renderEndTime.toFixed(2)}ms] DateDetailSheet render complete (took ${(renderEndTime - renderStartTime).toFixed(2)}ms)`);
    return (
        <View style={styles.container}>
            <Text style={styles.title}>{formatted}</Text>
            <View style={styles.empty}>
                <Ionicons name="calendar" size={50} color="#666" />
                <Text style={styles.emptyTitle}>No Workouts</Text>
                <Text style={styles.emptySub}>
                    You didn't work out on this day
                </Text>
            </View>
        </View>
    );
});

const styles = StyleSheet.create({
    container: { flex: 1, paddingTop: 20 },
    handle: {
        width: 40,
        height: 4,
        backgroundColor: "#666",
        borderRadius: 2,
        alignSelf: "center",
        marginBottom: 12,
    },
    title: {
        fontSize: 20,
        fontWeight: "600",
        color: "#fff",
        textAlign: "center",
        marginBottom: 40,
    },
    empty: { flex: 1, justifyContent: "center", alignItems: "center" },
    emptyTitle: {
        fontSize: 18,
        fontWeight: "600",
        color: "#fff",
        marginTop: 16,
    },
    emptySub: { fontSize: 16, color: "#999" },
});
