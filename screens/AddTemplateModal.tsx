import React, { useState } from "react";
import {
    View,
    Text,
    Modal,
    StyleSheet,
    SafeAreaView,
    TouchableOpacity,
    Dimensions,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { DaysSelectionModal } from "./DaysSelectionModal";
import { CustomNameModal } from "./CustomNameModal";
import { BodyPartsModal } from "./BodyPartsModal";

interface AddTemplateModalProps {
    visible: boolean;
    onClose: () => void;
}

const { height: screenHeight } = Dimensions.get("window");

const workoutNames = [
    "Custom",
    "Push",
    "Pull",
    "Full Body",
    "Upper Body",
    "Legs",
    "Body Parts",
];

export const AddTemplateModal: React.FC<AddTemplateModalProps> = ({
    visible,
    onClose,
}) => {
    const [selectedIndex, setSelectedIndex] = useState(0);
    const [showDays, setShowDays] = useState(false);
    const [showCustomName, setShowCustomName] = useState(false);
    const [showBodyParts, setShowBodyParts] = useState(false);

    const handleArrowTap = () => {
        const selectedName = workoutNames[selectedIndex];

        switch (selectedName) {
            case "Custom":
                setShowCustomName(true);
                break;
            case "Body Parts":
                setShowBodyParts(true);
                break;
            default:
                setShowDays(true);
                break;
        }
    };

    const handleCloseAll = () => {
        setShowDays(false);
        setShowCustomName(false);
        setShowBodyParts(false);
        onClose();
    };

    return (
        <>
            <Modal
                visible={visible}
                animationType="slide"
                presentationStyle="pageSheet"
            >
                <SafeAreaView style={styles.container}>
                    <View style={styles.header}>
                        <TouchableOpacity
                            onPress={onClose}
                            style={styles.cancelButton}
                        >
                            <Text style={styles.cancelText}>Cancel</Text>
                        </TouchableOpacity>
                        <Text style={styles.title}>Workout Name</Text>
                        <View style={styles.placeholder} />
                    </View>

                    <View style={styles.content}>
                        <View style={styles.pullIndicator}>
                            <Ionicons
                                name="chevron-down"
                                size={24}
                                color="rgba(255, 255, 255, 0.8)"
                            />
                        </View>
                    </View>
                </SafeAreaView>
            </Modal>

            <DaysSelectionModal
                visible={showDays}
                workoutName={workoutNames[selectedIndex]}
                onClose={handleCloseAll}
            />

            <CustomNameModal
                visible={showCustomName}
                onClose={handleCloseAll}
            />

            <BodyPartsModal visible={showBodyParts} onClose={handleCloseAll} />
        </>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#000000",
    },
    header: {
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
        paddingHorizontal: 16,
        paddingVertical: 12,
        borderBottomWidth: 0.5,
        borderBottomColor: "#3a3a3a",
    },
    cancelButton: {
        padding: 4,
    },
    cancelText: {
        fontSize: 17,
        color: "#FFFFFF",
    },
    title: {
        fontSize: 17,
        fontWeight: "600",
        color: "#FFFFFF",
    },
    placeholder: {
        width: 60,
    },
    content: {
        flex: 1,
    },
    pullIndicator: {
        alignItems: "center",
        paddingTop: 12,
    },
});
