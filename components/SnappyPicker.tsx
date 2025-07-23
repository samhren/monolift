import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  Animated,
  PanResponder,
  Dimensions,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface SnappyPickerProps {
  selectedIndex: number;
  items: string[];
  rowHeight: number;
  rowSpacing: number;
  viewHeight: number;
  decel: number;
  onArrowTap: () => void;
  onSelectionChange?: (index: number) => void;
}

const { width: screenWidth } = Dimensions.get('window');

export const SnappyPicker: React.FC<SnappyPickerProps> = ({
  selectedIndex,
  items,
  rowHeight,
  rowSpacing,
  viewHeight,
  decel,
  onArrowTap,
  onSelectionChange,
}) => {
  const [currentIndex, setCurrentIndex] = useState(selectedIndex);
  const translateY = useRef(new Animated.Value(0)).current;
  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {
        translateY.setOffset(translateY._value);
        translateY.setValue(0);
      },
      onPanResponderMove: (_, gestureState) => {
        translateY.setValue(gestureState.dy);
      },
      onPanResponderRelease: (_, gestureState) => {
        translateY.flattenOffset();
        
        const itemHeight = rowHeight + rowSpacing;
        const currentOffset = translateY._value;
        const velocity = gestureState.vy;
        
        // Calculate target index based on gesture
        let targetIndex = currentIndex;
        
        if (Math.abs(gestureState.dy) > 30 || Math.abs(velocity) > 0.5) {
          const direction = gestureState.dy < 0 ? 1 : -1;
          targetIndex = Math.max(0, Math.min(items.length - 1, currentIndex + direction));
        }
        
        // Update state
        setCurrentIndex(targetIndex);
        onSelectionChange?.(targetIndex);
        
        // Reset translateY
        Animated.spring(translateY, {
          toValue: 0,
          useNativeDriver: true,
          tension: 100,
          friction: 8,
        }).start();
      },
    })
  ).current;

  const centerY = viewHeight / 2;

  return (
    <View style={styles.container}>
      <Animated.View
        style={[
          styles.itemsContainer,
          {
            transform: [{ translateY }],
          },
        ]}
        {...panResponder.panHandlers}
      >
        {items.map((item, index) => {
          const distance = Math.abs(index - currentIndex);
          const scale = Math.max(0.6, 1 - distance * 0.15);
          const opacity = Math.max(0.3, 1 - distance * 0.25);
          const isSelected = index === currentIndex;

          return (
            <View
              key={index}
              style={[
                styles.itemRow,
                {
                  height: rowHeight,
                  marginBottom: rowSpacing,
                  transform: [{ scale }],
                  opacity,
                },
              ]}
            >
              <TouchableOpacity
                style={styles.itemButton}
                onPress={() => {
                  setCurrentIndex(index);
                  onSelectionChange?.(index);
                }}
              >
                <Text
                  style={[
                    styles.itemText,
                    {
                      color: isSelected ? '#FFFFFF' : '#666666',
                      fontWeight: isSelected ? 'bold' : 'normal',
                    },
                  ]}
                >
                  {item}
                </Text>
              </TouchableOpacity>
              
              {isSelected && (
                <TouchableOpacity style={styles.arrowButton} onPress={onArrowTap}>
                  <Ionicons name="chevron-forward" size={24} color="#FFFFFF" />
                </TouchableOpacity>
              )}
            </View>
          );
        })}
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  itemsContainer: {
    alignItems: 'center',
  },
  itemRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: screenWidth - 48,
    paddingHorizontal: 24,
  },
  itemButton: {
    flex: 1,
    justifyContent: 'center',
  },
  itemText: {
    fontSize: 36,
    fontWeight: 'bold',
    textAlign: 'left',
  },
  arrowButton: {
    padding: 8,
  },
});