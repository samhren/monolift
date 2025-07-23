import React, { useEffect } from "react";
import { Platform } from "react-native";
import { StatusBar } from "expo-status-bar";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { NavigationContainer } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import { CloudStorage, CloudStorageProvider } from "react-native-cloud-storage";
import { WorkoutProvider } from "./contexts/WorkoutContext";
import { WorkoutsScreen } from "./screens/WorkoutsScreen";
import { CalendarScreen } from "./screens/CalendarScreen";
import { ProgressScreen } from "./screens/ProgressScreen";
import { SettingsScreen } from "./screens/SettingsScreen";
import { PortalProvider } from "@gorhom/portal";
import { GestureHandlerRootView } from "react-native-gesture-handler";
const Tab = createBottomTabNavigator();

export default function App() {
    useEffect(() => {
        // Initialize cloud storage - on iOS this uses iCloud, on Android/Web it would use Google Drive
        if (Platform.OS === "ios") {
            // iCloud is automatically configured on iOS
            console.log("Using iCloud storage on iOS");
        } else {
            // For Android/Web, you'd need to configure Google Drive
            console.log("Cloud storage not configured for this platform");
        }
    }, []);

    return (
        <WorkoutProvider>
            <GestureHandlerRootView style={{ flex: 1 }}>
                <PortalProvider>
                    <NavigationContainer>
                        <StatusBar style="light" backgroundColor="#000000" />
                        <Tab.Navigator
                            screenOptions={({ route }) => ({
                                tabBarIcon: ({ focused, color, size }) => {
                                    let iconName: keyof typeof Ionicons.glyphMap;

                                    if (route.name === "Workouts") {
                                        iconName = focused
                                            ? "barbell"
                                            : "barbell-outline";
                                    } else if (route.name === "Calendar") {
                                        iconName = focused
                                            ? "calendar"
                                            : "calendar-outline";
                                    } else if (route.name === "Progress") {
                                        iconName = focused
                                            ? "trending-up"
                                            : "trending-up-outline";
                                    } else if (route.name === "Settings") {
                                        iconName = focused
                                            ? "settings"
                                            : "settings-outline";
                                    } else {
                                        iconName = "ellipse";
                                    }

                                    return (
                                        <Ionicons
                                            name={iconName}
                                            size={size}
                                            color={color}
                                        />
                                    );
                                },
                                tabBarActiveTintColor: "#FFFFFF",
                                tabBarInactiveTintColor: "#666666",
                                tabBarStyle: {
                                    backgroundColor: "#000000",
                                    borderTopColor: "transparent",
                                    height: 88,
                                    paddingBottom: 8,
                                },
                                tabBarLabelStyle: {
                                    fontSize: 12,
                                    fontWeight: "500",
                                },
                                headerShown: false,
                            })}
                        >
                            <Tab.Screen
                                name="Workouts"
                                component={WorkoutsScreen}
                            />
                            <Tab.Screen
                                name="Calendar"
                                component={CalendarScreen}
                            />
                            <Tab.Screen
                                name="Progress"
                                component={ProgressScreen}
                            />
                            <Tab.Screen
                                name="Settings"
                                component={SettingsScreen}
                            />
                        </Tab.Navigator>
                    </NavigationContainer>
                </PortalProvider>
            </GestureHandlerRootView>
        </WorkoutProvider>
    );
}
