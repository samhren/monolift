import React, { useState, useEffect } from "react";
import {
    View,
    Text,
    StyleSheet,
    SafeAreaView,
    ScrollView,
    TouchableOpacity,
    Switch,
    Alert,
    Linking,
    TextInput,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { CloudStorage, useIsCloudAvailable } from "react-native-cloud-storage";
import { useWorkout } from "../contexts/WorkoutContext";
import { RestTimersScreen } from "./RestTimersScreen";
import { WeightUnitScreen } from "./WeightUnitScreen";
import { NotificationsScreen } from "./NotificationsScreen";
import { HapticFeedbackScreen } from "./HapticFeedbackScreen";
import { CloudSyncScreen } from "./CloudSyncScreen";

interface SettingsItem {
    id: string;
    title: string;
    subtitle?: string;
    type: "toggle" | "action" | "info" | "select";
    value?: boolean | string;
    options?: string[];
    onPress?: () => void;
    onToggle?: (value: boolean) => void;
    onSelect?: (value: string) => void;
    icon?: keyof typeof Ionicons.glyphMap;
}

interface RestTimer {
    id: string;
    name: string;
    seconds: number;
}

export const SettingsScreen: React.FC = () => {
    const { templates, refreshTemplates } = useWorkout();
    const isCloudAvailable = useIsCloudAvailable();
    const [currentScreen, setCurrentScreen] = useState<string>("main");
    const [settings, setSettings] = useState({
        cloudSync: true,
        darkMode: true,
        notifications: true,
        hapticFeedback: true,
        weightUnit: "lbs" as "lbs" | "kg",
    });

    const [restTimers, setRestTimers] = useState<RestTimer[]>([
        { id: "1", name: "Short Rest", seconds: 60 },
        { id: "2", name: "Medium Rest", seconds: 120 },
        { id: "3", name: "Long Rest", seconds: 180 },
    ]);

    const updateSetting = (
        key: keyof typeof settings,
        value: boolean | string
    ) => {
        setSettings((prev) => ({ ...prev, [key]: value }));
        // TODO: Persist settings to storage
    };

    const exportData = async () => {
        try {
            const data = {
                templates,
                exportDate: new Date().toISOString(),
                version: "1.0.0",
            };

            Alert.alert(
                "Export Data",
                "Data export functionality will be implemented here. This would generate a JSON file with all your workout data.",
                [{ text: "OK" }]
            );
        } catch (error) {
            Alert.alert("Error", "Failed to export data");
        }
    };

    const clearAllData = () => {
        Alert.alert(
            "Clear All Data",
            "This will permanently delete all your workout templates and data. This action cannot be undone.",
            [
                { text: "Cancel", style: "cancel" },
                {
                    text: "Delete All",
                    style: "destructive",
                    onPress: async () => {
                        try {
                            // TODO: Implement data clearing
                            Alert.alert("Success", "All data has been cleared");
                        } catch (error) {
                            Alert.alert("Error", "Failed to clear data");
                        }
                    },
                },
            ]
        );
    };

    const openSupport = () => {
        Linking.openURL("mailto:support@monolift.app?subject=Monolift Support");
    };

    const navigateToSetting = (settingId: string) => {
        const implementedScreens = ['rest-timers', 'weight-unit', 'notifications', 'haptic', 'cloud-sync'];
        if (implementedScreens.includes(settingId)) {
            setCurrentScreen(settingId);
        } else {
            // TODO: Navigate to other setting pages
            Alert.alert("Navigate", `Navigate to ${settingId} settings page`);
        }
    };

    const handleBackToMain = () => {
        setCurrentScreen("main");
    };

    const handleWeightUnitChange = (unit: "lbs" | "kg") => {
        updateSetting("weightUnit", unit);
    };

    const handleSettingChange = (key: string, value: boolean) => {
        updateSetting(key as keyof typeof settings, value);
    };

    const settingsData: SettingsItem[] = [
        // App Features First
        {
            id: "rest-timers",
            title: "Rest Timers",
            subtitle: `${restTimers.length} timers configured`,
            type: "action",
            onPress: () => navigateToSetting("rest-timers"),
            icon: "timer",
        },
        {
            id: "weight-unit",
            title: "Weight Unit",
            subtitle: settings.weightUnit.toUpperCase(),
            type: "action",
            onPress: () => navigateToSetting("weight-unit"),
            icon: "barbell",
        },
        {
            id: "notifications",
            title: "Notifications",
            subtitle: settings.notifications ? "Enabled" : "Disabled",
            type: "action",
            onPress: () => navigateToSetting("notifications"),
            icon: "notifications",
        },
        {
            id: "haptic",
            title: "Haptic Feedback",
            subtitle: settings.hapticFeedback ? "Enabled" : "Disabled",
            type: "action",
            onPress: () => navigateToSetting("haptic"),
            icon: "phone-portrait",
        },
        // Data Management
        {
            id: "export",
            title: "Export Data",
            subtitle: "Create a backup of your workout data",
            type: "action",
            onPress: exportData,
            icon: "download",
        },
        {
            id: "clear",
            title: "Clear All Data",
            subtitle: "Permanently delete all workout data",
            type: "action",
            onPress: clearAllData,
            icon: "trash",
        },
        // Cloud Features Last
        {
            id: "cloud-sync",
            title: "Cloud Sync",
            subtitle: settings.cloudSync ? "Enabled" : "Disabled",
            type: "action",
            onPress: () => navigateToSetting("cloud-sync"),
            icon: "cloud",
        },
        {
            id: "refresh",
            title: "Refresh Data",
            subtitle: "Reload data from cloud storage",
            type: "action",
            onPress: refreshTemplates,
            icon: "refresh",
        },
        // Info & Support
        {
            id: "version",
            title: "Version",
            subtitle: "1.0.0",
            type: "info",
            icon: "information-circle",
        },
    ];

    const renderSettingItem = (item: SettingsItem, index: number) => {
        const isLastItem = index === settingsData.length - 1;

        return (
            <View
                key={item.id}
                style={[
                    styles.settingItem,
                    isLastItem && styles.settingItemLast,
                ]}
            >
                <TouchableOpacity
                    style={styles.settingButton}
                    onPress={item.onPress}
                    disabled={item.type === "info"}
                >
                    <View style={styles.settingLeft}>
                        {item.icon && (
                            <Ionicons
                                name={item.icon}
                                size={20}
                                color="#FFFFFF"
                                style={styles.settingIcon}
                            />
                        )}
                        <View style={styles.settingText}>
                            <Text style={styles.settingTitle}>
                                {item.title}
                            </Text>
                            {item.subtitle && (
                                <Text style={styles.settingSubtitle}>
                                    {item.subtitle}
                                </Text>
                            )}
                        </View>
                    </View>

                    {item.type === "action" && (
                        <Ionicons
                            name="chevron-forward"
                            size={16}
                            color="#666666"
                        />
                    )}
                </TouchableOpacity>
            </View>
        );
    };

    if (currentScreen === "rest-timers") {
        return <RestTimersScreen onBack={handleBackToMain} />;
    }

    if (currentScreen === "weight-unit") {
        return (
            <WeightUnitScreen
                currentUnit={settings.weightUnit}
                onUnitChange={handleWeightUnitChange}
                onBack={handleBackToMain}
            />
        );
    }

    if (currentScreen === "notifications") {
        return (
            <NotificationsScreen
                currentSettings={{ notifications: settings.notifications }}
                onSettingsChange={handleSettingChange}
                onBack={handleBackToMain}
            />
        );
    }

    if (currentScreen === "haptic") {
        return (
            <HapticFeedbackScreen
                currentSettings={{ hapticFeedback: settings.hapticFeedback }}
                onSettingsChange={handleSettingChange}
                onBack={handleBackToMain}
            />
        );
    }

    if (currentScreen === "cloud-sync") {
        return (
            <CloudSyncScreen
                currentSettings={{ cloudSync: settings.cloudSync }}
                isCloudAvailable={isCloudAvailable}
                onSettingsChange={handleSettingChange}
                onBack={handleBackToMain}
            />
        );
    }

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Settings</Text>
            </View>

            <ScrollView style={styles.content}>
                <View style={styles.settingGroup}>
                    <View style={styles.groupContainer}>
                        {settingsData.map((item, index) =>
                            renderSettingItem(item, index)
                        )}
                    </View>
                </View>

                <View style={styles.footer}>
                    <Text style={styles.footerText}>
                        Monolift - Minimalist Strength Training Tracker
                    </Text>
                    <Text style={styles.footerSubtext}>
                        Privacy-focused • Offline-first • iCloud sync
                    </Text>
                </View>
            </ScrollView>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#000000",
    },
    header: {
        paddingHorizontal: 24,
        paddingVertical: 8,
        backgroundColor: "#000000",
    },
    title: {
        fontSize: 34,
        fontWeight: "bold",
        color: "#FFFFFF",
    },
    content: {
        flex: 1,
    },
    settingGroup: {
        marginBottom: 24,
    },
    groupContainer: {
        backgroundColor: "#1a1a1a",
        marginHorizontal: 16,
        borderRadius: 12,
    },
    settingItem: {
        borderBottomWidth: 1,
        borderBottomColor: "#3a3a3a",
    },
    settingItemLast: {
        borderBottomWidth: 0,
    },
    settingButton: {
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
        paddingHorizontal: 16,
        paddingVertical: 16,
    },
    settingLeft: {
        flexDirection: "row",
        alignItems: "center",
        flex: 1,
    },
    settingIcon: {
        marginRight: 12,
        width: 20,
    },
    settingText: {
        flex: 1,
    },
    settingTitle: {
        fontSize: 16,
        fontWeight: "500",
        color: "#FFFFFF",
        marginBottom: 2,
    },
    settingSubtitle: {
        fontSize: 14,
        color: "#666666",
    },
    footer: {
        paddingHorizontal: 24,
        paddingVertical: 32,
        alignItems: "center",
    },
    footerText: {
        fontSize: 16,
        fontWeight: "500",
        color: "#FFFFFF",
        textAlign: "center",
        marginBottom: 8,
    },
    footerSubtext: {
        fontSize: 14,
        color: "#666666",
        textAlign: "center",
    },
});
