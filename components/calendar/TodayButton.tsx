import React from "react";
import { Animated, TouchableOpacity, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";

interface Props {
    direction: "up" | "down";
    opacity: Animated.Value;
    onPress: () => void;
}

export const TodayButton: React.FC<Props> = ({
    direction,
    opacity,
    onPress,
}) => (
    <Animated.View style={[styles.wrapper, { opacity }]}>
        <TouchableOpacity
            style={styles.inner}
            onPress={onPress}
            activeOpacity={0.8}
        >
            <Ionicons
                name={direction === "up" ? "chevron-up" : "chevron-down"}
                size={24}
                color="#fff"
            />
        </TouchableOpacity>
    </Animated.View>
);

const styles = StyleSheet.create({
    wrapper: {
        position: "absolute",
        bottom: 30,
        right: 24,
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: "#3a3a3a",
        elevation: 5,
    },
    inner: {
        flex: 1,
        borderRadius: 24,
        justifyContent: "center",
        alignItems: "center",
    },
});
