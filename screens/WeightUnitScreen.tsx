import React, { useState } from "react";
import {
    View,
    Text,
    StyleSheet,
    SafeAreaView,
    TouchableOpacity,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";

interface Props {
    currentUnit: "lbs" | "kg";
    onUnitChange: (unit: "lbs" | "kg") => void;
    onBack: () => void;
}

export const WeightUnitScreen: React.FC<Props> = ({
    currentUnit,
    onUnitChange,
    onBack,
}) => {
    const [selectedUnit, setSelectedUnit] = useState<"lbs" | "kg">(currentUnit);

    console.log(
        "WeightUnitScreen render - currentUnit:",
        currentUnit,
        "selectedUnit:",
        selectedUnit
    );

    const handleUnitSelect = (unit: "lbs" | "kg") => {
        setSelectedUnit(unit);
        onUnitChange(unit);
    };

    const weightUnits = [
        {
            value: "lbs" as const,
            label: "Pounds (lbs)",
        },
        {
            value: "kg" as const,
            label: "Kilograms (kg)",
        },
    ];

    console.log("weightUnits:", weightUnits);

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <TouchableOpacity style={styles.backButton} onPress={onBack}>
                    <Ionicons name="arrow-back" size={24} color="#FFFFFF" />
                </TouchableOpacity>
                <Text style={styles.title}>Weight Unit</Text>
                <View style={styles.headerSpacer} />
            </View>

            <View style={styles.content}>
                <View style={styles.settingGroup}>
                    <View style={styles.groupContainer}>
                        {weightUnits.map((unit, index) => (
                            <TouchableOpacity
                                key={unit.value}
                                style={[
                                    styles.unitOption,
                                    selectedUnit === unit.value &&
                                        styles.unitOptionSelected,
                                    index === weightUnits.length - 1 &&
                                        styles.unitOptionLast,
                                    index === 0 && styles.unitOptionFirst,
                                ]}
                                onPress={() => handleUnitSelect(unit.value)}
                            >
                                <View style={styles.unitHeader}>
                                    <Text style={styles.unitLabel}>
                                        {unit.label}
                                    </Text>
                                    {selectedUnit === unit.value && (
                                        <Ionicons
                                            name="checkmark-circle"
                                            size={20}
                                            color="#FFFFFF"
                                        />
                                    )}
                                </View>
                            </TouchableOpacity>
                        ))}
                    </View>
                </View>

                <View style={styles.footer}>
                    <Text style={styles.footerText}>
                        This setting affects how weights are displayed
                        throughout the app. Your existing workout data will be
                        automatically converted when you switch units.
                    </Text>
                </View>
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#000000",
    },
    header: {
        flexDirection: "row",
        alignItems: "center",
        paddingHorizontal: 24,
        paddingVertical: 16,
        backgroundColor: "#000000",
    },
    backButton: {
        padding: 4,
    },
    title: {
        fontSize: 24,
        fontWeight: "bold",
        color: "#FFFFFF",
        flex: 1,
        textAlign: "center",
    },
    headerSpacer: {
        width: 32,
    },
    content: {
        flex: 1,
        paddingTop: 20,
    },
    settingGroup: {
        marginBottom: 24,
    },
    groupContainer: {
        backgroundColor: "#1a1a1a",
        marginHorizontal: 16,
        borderRadius: 12,
    },
    unitOption: {
        paddingHorizontal: 16,
        paddingVertical: 16,
        borderBottomWidth: 1,
        borderBottomColor: "#3a3a3a",
    },
    unitOptionSelected: {
        backgroundColor: "#2a2a2a",
    },
    unitOptionFirst: {
        borderTopLeftRadius: 12,
        borderTopRightRadius: 12,
    },
    unitOptionLast: {
        borderBottomWidth: 0,
        borderBottomLeftRadius: 12,
        borderBottomRightRadius: 12,
    },
    unitHeader: {
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
    },
    unitLabel: {
        fontSize: 18,
        fontWeight: "bold",
        color: "#FFFFFF",
    },
    footer: {
        paddingHorizontal: 24,
        paddingVertical: 32,
        alignItems: "center",
    },
    footerText: {
        fontSize: 14,
        color: "#999999",
        textAlign: "center",
        lineHeight: 20,
    },
});
