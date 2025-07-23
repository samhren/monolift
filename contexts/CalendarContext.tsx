import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { generateMonthsData } from '../utils/date';
import { MonthData } from '../types/calendar';

interface CalendarContextValue {
  monthsData: MonthData[];
  isLoading: boolean;
  monthRange: { start: number; end: number };
}

const CalendarContext = createContext<CalendarContextValue | undefined>(undefined);

interface CalendarProviderProps {
  children: ReactNode;
}

const MONTH_RANGE = { start: -12, end: 24 }; // 3 years total

export const CalendarProvider: React.FC<CalendarProviderProps> = ({ children }) => {
  const [monthsData, setMonthsData] = useState<MonthData[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Preload calendar data on app startup
    const loadCalendarData = async () => {
      console.log('[Calendar] Starting calendar data preload...');
      const startTime = performance.now();
      
      // Use setTimeout to avoid blocking the main thread
      setTimeout(() => {
        try {
          const data = generateMonthsData(MONTH_RANGE);
          setMonthsData(data);
          
          const endTime = performance.now();
          console.log(`[Calendar] Calendar data preloaded in ${(endTime - startTime).toFixed(2)}ms`);
        } catch (error) {
          console.error('[Calendar] Error preloading calendar data:', error);
        } finally {
          setIsLoading(false);
        }
      }, 0);
    };

    loadCalendarData();
  }, []);

  const value: CalendarContextValue = {
    monthsData,
    isLoading,
    monthRange: MONTH_RANGE,
  };

  return (
    <CalendarContext.Provider value={value}>
      {children}
    </CalendarContext.Provider>
  );
};

export const useCalendar = (): CalendarContextValue => {
  const context = useContext(CalendarContext);
  if (context === undefined) {
    throw new Error('useCalendar must be used within a CalendarProvider');
  }
  return context;
};