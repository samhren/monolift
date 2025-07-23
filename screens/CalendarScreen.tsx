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
import { Portal } from "@gorhom/portal";

import { CalendarGrid } from "../components/calendar/CalendarGrid";
import { TodayButton } from "../components/calendar/TodayButton";
import { DateDetailSheet } from "../components/calendar/DateDetailSheet";

/* ───────────────────────────── Constants ──────────────────────────── */

const windowHeight = Dimensions.get("window").height;
const CONTENT_HEIGHT = windowHeight * 0.3; // 30 % of screen
const COLLAPSED_HEIGHT = 10; // slim bar

const SNAP_POINTS = [COLLAPSED_HEIGHT, CONTENT_HEIGHT];

/* ───────────────────────────── Component ──────────────────────────── */

export const CalendarScreen: React.FC = () => {
    /* timing config must live **inside** the component (hook) */
    const TIMING_400 = useBottomSheetTimingConfigs({
        duration: 400,
        easing: Easing.out(Easing.cubic),
    });

    /* header + FAB state */
    const [year, setYear] = useState(new Date().getFullYear());
    const [showBtn, setShowBtn] = useState(false);
    const [dir, setDir] = useState<"up" | "down">("up");
    const opacity = useRef(new Animated.Value(0)).current;

    /* two sheets + their dates */
    const refA = useRef<BottomSheet>(null);
    const refB = useRef<BottomSheet>(null);
    const indexARef = useRef(-1);
    const indexBRef = useRef(-1);
    const [activeSheet, setActiveSheet] = useState<"A" | "B">("A");
    const [dateA, setDateA] = useState<Date | null>(null);
    const [dateB, setDateB] = useState<Date | null>(null);

    /* today‑centering helper from CalendarGrid */
    const centerOnTodayRef = useRef<(() => void) | null>(null);

    /* bounce the first sheet on mount (makes handle visible) */
    useLayoutEffect(() => {
        InteractionManager.runAfterInteractions(() => {
            refA.current?.expand();
            requestAnimationFrame(() => refA.current?.close());
        });
    }, []);

    /* ─────── Helper to switch sheets without flashing ─────── */

    const showDate = useCallback(
        (next: Date) => {
            // /* skip if already showing */
            // const current =
            //     activeSheet === "A" ? dateA?.getTime() : dateB?.getTime();
            // if (current === next.getTime()) return;

            // const isAActive = activeSheet === "A";
            // const topRef = isAActive ? refA : refB; // currently visible
            // const bottomRef = isAActive ? refB : refA; // hidden one
            // const setBottomDate = isAActive ? setDateB : setDateA;
            // const bringToFront = isAActive ? "B" : "A";
            const isAActive = activeSheet === "A";
            const topRef = isAActive ? refA : refB;
            const bottomRef = isAActive ? refB : refA;
            const setBottomDate = isAActive ? setDateB : setDateA;
            const bringToFront = isAActive ? "B" : "A";

            const sameDate =
                (isAActive ? dateA : dateB)?.getTime() === next.getTime();

            /* ❯ look up the *stored* index instead of calling a method */
            const topIndex = isAActive ? indexARef.current : indexBRef.current;

            /* reopen if closed, skip if already open */
            if (sameDate && topIndex === -1) {
                topRef.current?.snapToIndex(1, TIMING_400);
                return;
            }
            if (sameDate) return;

            /* 1️⃣ prerender hidden sheet with the new date */
            setBottomDate(next);

            /* 2️⃣ wait until React commits that update BEFORE animating */
            InteractionManager.runAfterInteractions(() => {
                /* rise beneath */
                bottomRef.current?.snapToIndex(1, TIMING_400);
                /* drop current on top */
                topRef.current?.snapToIndex(0, TIMING_400);

                /* 3️⃣ swap z‑order when the animation completes */
                // setTimeout(
                //     () => setActiveSheet(bringToFront),
                //     TIMING_400.duration
                // );
                setTimeout(() => {
                    setActiveSheet(bringToFront);
                    topRef.current?.close();
                }, TIMING_400.duration);
            });
        },
        [activeSheet, dateA, dateB, TIMING_400]
    );

    /* ─────── Animated FAB helpers ─────── */

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

    /* ─────────────────────────── Render ───────────────────────────── */

    return (
        <SafeAreaView style={styles.container}>
            {/* ── Header ── */}
            <View style={styles.header}>
                <Text style={styles.title}>Calendar</Text>
                <Text style={styles.year}>{year}</Text>
            </View>

            {/* ── Calendar grid ── */}
            <CalendarGrid
                onCenterOnToday={(fn) => (centerOnTodayRef.current = fn)}
                onDatePress={showDate}
                onYearChange={setYear}
                onTodayVisibility={({ visible, direction }) => {
                    if (visible && !showBtn) {
                        setShowBtn(true);
                        setDir(direction);
                        opacity.setValue(0);
                        fadeIn();
                    }
                    if (!visible && showBtn) fadeOut();
                }}
            />

            {/* ── Floating today button ── */}
            {showBtn && (
                <TodayButton
                    direction={dir}
                    opacity={opacity}
                    onPress={() => {
                        activeSheet === "A"
                            ? refA.current?.close()
                            : refB.current?.close();
                        centerOnTodayRef.current?.();
                    }}
                />
            )}

            {/* ── Two layered sheets ── */}
            <Portal>
                {/* Sheet A */}
                <BottomSheet
                    ref={refA}
                    index={-1}
                    snapPoints={SNAP_POINTS}
                    containerHeight={windowHeight}
                    enablePanDownToClose
                    animationConfigs={TIMING_400}
                    backgroundStyle={{ backgroundColor: "#2a2a2a" }}
                    // @ts-ignore
                    handleHeight={24 as any}
                    contentHeight={CONTENT_HEIGHT}
                    style={{ zIndex: activeSheet === "A" ? 2 : 1 }}
                    onChange={(index) => {
                        indexARef.current = index;
                    }}
                >
                    <BottomSheetView
                        key={dateA?.toDateString() || "none"}
                        style={styles.contentContainer}
                    >
                        <DateDetailSheet date={dateA} />
                    </BottomSheetView>
                </BottomSheet>

                {/* Sheet B */}
                <BottomSheet
                    ref={refB}
                    index={-1}
                    snapPoints={SNAP_POINTS}
                    containerHeight={windowHeight}
                    enablePanDownToClose
                    animationConfigs={TIMING_400}
                    backgroundStyle={{ backgroundColor: "#2a2a2a" }}
                    // @ts-ignore
                    handleHeight={24 as any}
                    contentHeight={CONTENT_HEIGHT}
                    style={{ zIndex: activeSheet === "B" ? 2 : 1 }}
                    onChange={(index) => {
                        indexBRef.current = index;
                    }}
                >
                    <BottomSheetView
                        key={dateB?.toDateString() || "none"}
                        style={styles.contentContainer}
                    >
                        <DateDetailSheet date={dateB} />
                    </BottomSheetView>
                </BottomSheet>
            </Portal>
        </SafeAreaView>
    );
};

/* ───────────────────────────── Styles ───────────────────────────── */

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
