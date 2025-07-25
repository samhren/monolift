// CalendarScreen.tsx
import React, { useRef, useState, useLayoutEffect, useCallback } from "react";
import {
    View,
    Text,
    SafeAreaView,
    StyleSheet,
    Animated,
    Dimensions,
    InteractionManager,
} from "react-native";
import { Easing } from "react-native-reanimated";
import BottomSheet, {
    BottomSheetView,
    useBottomSheetTimingConfigs,
} from "@gorhom/bottom-sheet";
import { Portal } from "@gorhom/portal";

import { CalendarGrid } from "../components/calendar/CalendarGrid";
import { TodayButton } from "../components/calendar/TodayButton";
import { DateDetailSheet } from "../components/calendar/DateDetailSheet";

const windowHeight = Dimensions.get("window").height;
const CONTENT_HEIGHT = windowHeight * 0.3;
const SNAP_POINTS = [CONTENT_HEIGHT];

export const CalendarScreen: React.FC = () => {
    const TIMING_400 = useBottomSheetTimingConfigs({
        duration: 400,
        easing: Easing.out(Easing.cubic),
    });

    const TIMING_CLOSE = useBottomSheetTimingConfigs({
        duration: 100, // <– very snappy
        easing: Easing.out(Easing.cubic),
    });

    // year + FAB state
    const [year, setYear] = useState(new Date().getFullYear());
    const [showBtn, setShowBtn] = useState(false);
    const [dir, setDir] = useState<"up" | "down">("up");
    const opacity = useRef(new Animated.Value(0)).current;

    // ** single sheet state **
    const sheetRef = useRef<BottomSheet>(null);
    const [sheetIndex, setSheetIndex] = useState<number>(-1);
    const [selectedDate, setSelectedDate] = useState<Date | null>(null);
    const isTransitioning = useRef(false);

    // bounce handle on mount
    useLayoutEffect(() => {
        InteractionManager.runAfterInteractions(() => {
            sheetRef.current?.expand();
            requestAnimationFrame(() => sheetRef.current?.close());
        });
    }, []);

    // show/hide the FAB
    const onTodayVisibility = useCallback(
        ({
            visible,
            direction,
        }: {
            visible: boolean;
            direction: "up" | "down";
        }) => {
            if (visible && !showBtn) {
                setShowBtn(true);
                setDir(direction);
                opacity.setValue(0);
                Animated.timing(opacity, {
                    toValue: 1,
                    duration: 200,
                    useNativeDriver: true,
                }).start();
            }
            if (!visible && showBtn) {
                Animated.timing(opacity, {
                    toValue: 0,
                    duration: 50,
                    useNativeDriver: true,
                }).start(() => setShowBtn(false));
            }
        },
        [showBtn, opacity]
    );

    // ─── the one, unified showDate fn with bob animation ───
    const showDate = useCallback(
        (date: Date) => {
            const same = selectedDate?.getTime() === date.getTime();

            if (same) {
                // if it's already open, close **and** clear immediately
                if (sheetIndex !== -1) {
                    setSelectedDate(null);
                    sheetRef.current?.close();
                } else {
                    // if closed, just re‑open
                    sheetRef.current?.snapToIndex(0, TIMING_400);
                }
                return;
            }

            // For new date selection: bob down animation
            if (selectedDate && sheetIndex !== -1) {
                // Set transition flag to prevent clearing selectedDate
                isTransitioning.current = true;
                
                // Update date immediately to prevent empty state
                setSelectedDate(date);
                
                // Animate sheet down and back up with new content
                sheetRef.current?.snapToIndex(-1, TIMING_CLOSE);
                
                // After close animation, reopen with new data
                setTimeout(() => {
                    sheetRef.current?.snapToIndex(0, TIMING_400);
                    // Clear transition flag after full animation
                    setTimeout(() => {
                        isTransitioning.current = false;
                    }, 400);
                }, 100); // Match TIMING_CLOSE duration
            } else {
                // First selection or no previous selection
                setSelectedDate(date);
                requestAnimationFrame(() => {
                    sheetRef.current?.snapToIndex(0, TIMING_400);
                });
            }
        },
        [selectedDate, sheetIndex, TIMING_400, TIMING_CLOSE]
    );

    return (
        <SafeAreaView style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.title}>Calendar</Text>
                <Text style={styles.year}>{year}</Text>
            </View>

            {/* Grid */}
            <CalendarGrid
                onCenterOnToday={(fn) => fn && fn()}
                onDatePress={showDate}
                onYearChange={setYear}
                selectedDate={selectedDate}
                isBottomSheetOpen={Boolean(selectedDate)}
                onTodayVisibility={onTodayVisibility}
            />

            {/* Today FAB */}
            {showBtn && (
                <TodayButton
                    direction={dir}
                    opacity={opacity}
                    onPress={() => {
                        setSelectedDate(null);
                        sheetRef.current?.close();
                        // center callback if you keep that ref
                    }}
                />
            )}

            {/* Single BottomSheet */}
            <Portal>
                <BottomSheet
                    ref={sheetRef}
                    index={-1}
                    snapPoints={SNAP_POINTS}
                    enablePanDownToClose
                    animationConfigs={TIMING_400}
                    backgroundStyle={{ backgroundColor: "#2a2a2a" }}
                    // @ts-ignore
                    handleHeight={24}
                    containerHeight={windowHeight}
                    onChange={(i) => {
                        setSheetIndex(i);
                        if (i === -1 && !isTransitioning.current) {
                            // Only clear selection if not transitioning between dates
                            setSelectedDate(null);
                        }
                    }}
                >
                    <BottomSheetView style={styles.contentContainer}>
                        <DateDetailSheet date={selectedDate} />
                    </BottomSheetView>
                </BottomSheet>
            </Portal>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: "#000" },
    header: {
        flexDirection: "row",
        alignItems: "baseline",
        justifyContent: "space-between",
        paddingHorizontal: 12,
        paddingVertical: 8,
    },
    title: { fontSize: 34, fontWeight: "bold", color: "#fff" },
    year: { fontSize: 18, fontWeight: "500", color: "#3a3a3a" },
    contentContainer: {
        flex: 1,
        paddingHorizontal: 16,
    },
});
