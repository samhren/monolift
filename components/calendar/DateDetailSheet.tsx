import React, { memo } from "react";
import { View, Text, StyleSheet, TouchableOpacity } from "react-native";
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

    // Determine if date is past, present, or future
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const selectedDate = new Date(date);
    selectedDate.setHours(0, 0, 0, 0);
    
    const isPast = selectedDate < today;
    const isToday = selectedDate.getTime() === today.getTime();
    const isFuture = selectedDate > today;

    // Get appropriate content based on date context
    const getEmptyStateContent = () => {
        if (isToday) {
            return {
                icon: "today-outline" as const,
                title: "Today's Workout",
                subtitle: "No workout logged yet today",
                actionText: "Start Workout",
                iconColor: "#007AFF",
            };
        } else if (isPast) {
            return {
                icon: "calendar-outline" as const,
                title: "No Workouts Logged",
                subtitle: "You didn't work out on this day",
                actionText: null,
                iconColor: "#666",
            };
        } else {
            return {
                icon: "calendar-outline" as const,
                title: "No Workout Planned",
                subtitle: "No workout scheduled for this day",
                actionText: "Plan Workout",
                iconColor: "#007AFF",
            };
        }
    };

    const content = getEmptyStateContent();
    const renderEndTime = performance.now();
    console.log(`[${renderEndTime.toFixed(2)}ms] DateDetailSheet render complete (took ${(renderEndTime - renderStartTime).toFixed(2)}ms)`);

    return (
        <View style={styles.container}>
            <Text style={styles.title}>{formatted}</Text>
            <View style={styles.content}>
                <View style={styles.iconContainer}>
                    <Ionicons name={content.icon} size={32} color={content.iconColor} />
                </View>
                <View style={styles.textContainer}>
                    <Text style={styles.emptyTitle}>{content.title}</Text>
                    <Text style={styles.emptySub}>{content.subtitle}</Text>
                </View>
                {content.actionText && (
                    <TouchableOpacity style={styles.actionButton}>
                        <Text style={styles.actionButtonText}>{content.actionText}</Text>
                    </TouchableOpacity>
                )}
            </View>
        </View>
    );
});

const styles = StyleSheet.create({
    container: { 
        paddingTop: 20,
        paddingBottom: 20,
        paddingHorizontal: 16,
    },
    handle: {
        width: 40,
        height: 4,
        backgroundColor: "#666",
        borderRadius: 2,
        alignSelf: "center",
        marginBottom: 12,
    },
    title: {
        fontSize: 18,
        fontWeight: "600",
        color: "#fff",
        textAlign: "center",
        marginBottom: 20,
    },
    content: { 
        flexDirection: "row",
        alignItems: "center",
        paddingVertical: 16,
        paddingHorizontal: 20,
        backgroundColor: "#1a1a1a",
        borderRadius: 12,
    },
    iconContainer: {
        marginRight: 16,
    },
    textContainer: {
        flex: 1,
    },
    emptyTitle: {
        fontSize: 16,
        fontWeight: "600",
        color: "#fff",
        marginBottom: 2,
    },
    emptySub: { 
        fontSize: 14, 
        color: "#999",
    },
    actionButton: {
        backgroundColor: "#007AFF",
        paddingHorizontal: 16,
        paddingVertical: 8,
        borderRadius: 6,
        marginLeft: 12,
    },
    actionButtonText: {
        color: "#fff",
        fontSize: 14,
        fontWeight: "600",
    },
});
