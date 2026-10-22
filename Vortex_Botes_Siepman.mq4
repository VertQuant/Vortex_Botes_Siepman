//+------------------------------------------------------------------+
//| Vortex_Botes_Siepman.mq4                                          |
//| Version: 1.00                                                     |
//| Free to use and distribute. No warranty.                          |
//+------------------------------------------------------------------+
#property copyright   "VertQuant, 2026"
#property link        "https://www.youtube.com/@VertQuant"
#property description "Vortex_Botes_Siepman - directional momentum vs volatility"
#property version     "1.00"
//+------------------------------------------------------------------
// Concept of directional movement relative to volatility:
// Botes E., Siepman D. - "The Vortex Indicator",
// Technical Analysis of Stocks & Commodities, Jan 2010 (vol. 28, no. 1).
//
// The calculation formula and the indicator code are an original
// VertQuant implementation (EMA smoothing of directional movement
// instead of a rolling sum, ATR-based normalization, and a separate
// confirmed-threshold signal).
//
// Parameters:
//   InpPeriod    - EMA smoothing period and ATR period (default 14)
//   InpThreshold - VI+/VI- difference threshold that triggers
//                  a signal arrow when exceeded (default 0.15)
//
// This is educational material. The indicator is not trading advice
// and does not guarantee profit. Free to use, modify and distribute,
// provided the original concept is credited to Botes/Siepman.
//+------------------------------------------------------------------
#property strict
#property indicator_separate_window
#property indicator_buffers 6

//--- input parameters
input int    InpPeriod    = 14;    // Smoothing / ATR period
input double InpThreshold = 0.15;  // Signal confirmation threshold

//--- displayed buffers
double VIPlus[];     // "+" line (TURQUOISE)
double VIMinus[];    // "-" line (ORANGE)
double SignalUp[];   // up arrow (GOLD) - confirmed signal
double SignalDn[];   // down arrow (GOLD) - confirmed signal

//--- calculation-only buffers (smoothed VM+/VM-, EMA)
double EmaUp[];
double EmaDn[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, VIPlus);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, C'0,212,198');     // TURQUOISE #00D4C6
   SetIndexLabel(0, "VI+");

   SetIndexBuffer(1, VIMinus);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, C'255,179,71');    // ORANGE #FFB347
   SetIndexLabel(1, "VI-");

   SetIndexBuffer(2, SignalUp);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 2, C'255,215,0');    // GOLD #FFD700
   SetIndexArrow(2, 233); // up arrow
   SetIndexLabel(2, "Signal Up");
   SetIndexEmptyValue(2, EMPTY_VALUE);

   SetIndexBuffer(3, SignalDn);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2, C'255,215,0');    // GOLD #FFD700
   SetIndexArrow(3, 234); // down arrow
   SetIndexLabel(3, "Signal Down");
   SetIndexEmptyValue(3, EMPTY_VALUE);

   SetIndexBuffer(4, EmaUp);
   SetIndexStyle(4, DRAW_NONE);

   SetIndexBuffer(5, EmaDn);
   SetIndexStyle(5, DRAW_NONE);

   IndicatorShortName("Vortex_Botes_Siepman (" + IntegerToString(InpPeriod) + "," + DoubleToString(InpThreshold, 2) + ")");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[])
  {
   if(rates_total < InpPeriod + 2)
      return(0);

//--- keep chart-style indexing: index 0 = the most recent bar
   ArraySetAsSeries(time,  true);
   ArraySetAsSeries(open,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);

   int counted_bars = prev_calculated;
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;

//--- oldest calculated bar: the EMA is seeded here, nothing older is ever read
   int seedBar = rates_total - InpPeriod - 2;

   int limit = rates_total - counted_bars;
   if(limit > seedBar) limit = seedBar;
   if(limit < 0) limit = 0;

   double alpha = 2.0 / (InpPeriod + 1.0);

   for(int i = limit; i >= 0; i--)
     {
      //--- raw directional movement (VM+/VM-), compared to the previous (older) bar
      double rawUp = MathAbs(high[i] - low[i + 1]);
      double rawDn = MathAbs(low[i]  - high[i + 1]);

      //--- EMA smoothing instead of a rolling sum (exponential weight on recent bars)
      if(i < seedBar)
        {
         EmaUp[i] = alpha * rawUp + (1.0 - alpha) * EmaUp[i + 1];
         EmaDn[i] = alpha * rawDn + (1.0 - alpha) * EmaDn[i + 1];
        }
      else
        {
         EmaUp[i] = rawUp;
         EmaDn[i] = rawDn;
        }

      //--- normalize against volatility using the built-in ATR
      double atr = iATR(NULL, 0, InpPeriod, i);
      if(atr != 0)
        {
         VIPlus[i]  = EmaUp[i] / atr;
         VIMinus[i] = EmaDn[i] / atr;
        }
      else
        {
         VIPlus[i]  = 0;
         VIMinus[i] = 0;
        }

      //--- signal: confirmed threshold crossing (not every tiny line crossover)
      SignalUp[i] = EMPTY_VALUE;
      SignalDn[i] = EMPTY_VALUE;

      if(i < seedBar)
        {
         double diffCur  = VIPlus[i] - VIMinus[i];
         double diffPrev = VIPlus[i + 1] - VIMinus[i + 1];

         if(diffCur > InpThreshold && diffPrev <= InpThreshold)
            SignalUp[i] = low[i] - 3 * Point;

         if(diffCur < -InpThreshold && diffPrev >= -InpThreshold)
            SignalDn[i] = high[i] + 3 * Point;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
