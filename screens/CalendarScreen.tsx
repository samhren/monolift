import React, {
    useRef,
    useState,
    useMemo,
    useCallback,
    useLayoutEffect,
} from "react";
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
import { CalendarGrid } from "../components/calendar/CalendarGrid";
import { Portal } from "@gorhom/portal";
import { TodayButton } from "../components/calendar/TodayButton";
import { DateDetailSheet } from "../components/calendar/DateDetailSheet";

export const CalendarScreen: React.FC = () => {
    const [selectedDate, setSelectedDate] = useState<Date | null>(null);
    const [year, setYear] = useState(new Date().getFullYear());
    const [showBtn, setShowBtn] = useState(false);
    const [dir, setDir] = useState<"up" | "down">("up");
    const opacity = useRef(new Animated.Value(0)).current;
    const bottomSheetRef = useRef<BottomSheet>(null);
    const centerOnTodayRef = useRef<(() => void) | null>(null);
    const windowHeight = Dimensions.get("window").height;
    const contentHeight = windowHeight * 0.3;
    const snapPoints = useMemo(() => [contentHeight], [contentHeight]);
    const animationConfigs = useBottomSheetTimingConfigs({
        duration: 200,
        easing: Easing.out(Easing.cubic),
    });

    useLayoutEffect(() => {
        InteractionManager.runAfterInteractions(() => {
            const sheet = bottomSheetRef.current;
            if (sheet) {
                sheet.expand();
                requestAnimationFrame(() => {
                    sheet.close();
                });
            }
        });
    }, []);

    const handleSheetChanges = useCallback((index: number) => {
        const changeTime = performance.now();
        console.log(
            `[${changeTime.toFixed(2)}ms] BottomSheet handleSheetChanges:`,
            index
        );
    }, []);

    /** floating‑button helpers */
    const fadeIn = () =>
        Animated.timing(opacity, {
            toValue: 1,
            duration: 200,
            useNativeDriver: true,
        }).start();
    const fadeOut = () =>
        Animated.timing(opacity, {
            toValue: 0,
            duration: 50,
            useNativeDriver: true,
        }).start(() => setShowBtn(false));

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Calendar</Text>
                <Text style={styles.year}>{year}</Text>
            </View>

            <CalendarGrid
                monthRange={{ start: -12, end: 24 }}
                onCenterOnToday={(centerFn) => {
                    centerOnTodayRef.current = centerFn;
                }}
                onDatePress={(d) => {
                    const callbackStartTime = performance.now();
                    console.log(
                        `[${callbackStartTime.toFixed(
                            2
                        )}ms] CalendarScreen onDatePress:`,
                        d
                    );

                    const setStateStartTime = performance.now();
                    setSelectedDate(d);
                    const setStateEndTime = performance.now();
                    console.log(
                        `[${setStateEndTime.toFixed(
                            2
                        )}ms] setSelectedDate finished (took ${(
                            setStateEndTime - setStateStartTime
                        ).toFixed(2)}ms)`
                    );

                    console.log(
                        `[${performance
                            .now()
                            .toFixed(2)}ms] About to expand bottom sheet`
                    );
                    console.log(
                        `[${performance
                            .now()
                            .toFixed(2)}ms] bottomSheetRef.current:`,
                        bottomSheetRef.current
                    );

                    if (bottomSheetRef.current) {
                        const expandStartTime = performance.now();
                        console.log(
                            `[${expandStartTime.toFixed(2)}ms] Calling expand()`
                        );
                        bottomSheetRef.current.expand();
                        const expandEndTime = performance.now();
                        console.log(
                            `[${expandEndTime.toFixed(
                                2
                            )}ms] expand called (took ${(
                                expandEndTime - expandStartTime
                            ).toFixed(2)}ms)`
                        );
                    } else {
                        console.log(
                            `[${performance
                                .now()
                                .toFixed(
                                    2
                                )}ms] bottomSheetRef.current is null/undefined`
                        );
                    }

                    const callbackEndTime = performance.now();
                    console.log(
                        `[${callbackEndTime.toFixed(
                            2
                        )}ms] Total onDatePress callback finished (took ${(
                            callbackEndTime - callbackStartTime
                        ).toFixed(2)}ms)`
                    );
                }}
                onYearChange={setYear}
                onTodayVisibility={({ visible, direction }) => {
                    if (visible && !showBtn) {
                        setShowBtn(true);
                        setDir(direction);
                        opacity.setValue(0);
                        fadeIn();
                    }
                    if (!visible && showBtn) {
                        fadeOut();
                    }
                }}
            />

            {showBtn && (
                <TodayButton
                    direction={dir}
                    opacity={opacity}
                    onPress={() => {
                        bottomSheetRef.current?.close();
                        if (centerOnTodayRef.current) {
                            centerOnTodayRef.current();
                        }
                    }}
                />
            )}
            <Portal>
                <BottomSheet
                    ref={bottomSheetRef}
                    index={-1}
                    animateOnMount={false}
                    enableDynamicSizing={false}
                    containerHeight={windowHeight}
                    animationConfigs={animationConfigs}
                    snapPoints={snapPoints}
                    enablePanDownToClose
                    backgroundStyle={{ backgroundColor: "#2a2a2a" }}
                    onChange={handleSheetChanges}
                    // @ts-expect-error
                    handleHeight={24}
                    contentHeight={contentHeight}
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
