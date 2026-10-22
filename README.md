# Vortex_Botes_Siepman

A free MQL4 indicator for MetaTrader 4 that measures directional price
movement relative to volatility, visualized as two lines (VI+ / VI-)
plus a confirmed-crossover signal arrow.

Published by **[VertQuant](https://www.youtube.com/@VertQuant)** —
honest, statistics-backed testing of trading indicators on YouTube.

## Concept credit

The underlying concept — comparing directional movement to volatility
via two complementary lines — originates from:

> Botes, E. & Siepman, D. (2010). *The Vortex Indicator*.
> Technical Analysis of Stocks & Commodities, January 2010 (vol. 28, no. 1).

The calculation formula and the full code in this repository are an
original VertQuant implementation and differ from the original Vortex
Indicator in several ways (see below). If you redistribute or modify
this indicator, please keep credit to the original concept authors.

## What's different from the classic Vortex Indicator

| | Classic Vortex Indicator (Botes & Siepman, 2010) | Vortex_Botes_Siepman |
|---|---|---|
| Smoothing | Rolling sum over N bars | EMA (exponential, recent bars weighted more) |
| Normalization | Sum of True Range over N bars | Built-in ATR(period) |
| Signal | Any VI+/VI- line crossover | Crossover confirmed by a threshold (filters noise) |

## Installation

1. Download `Vortex_Botes_Siepman.mq4` from this repository.
2. Open MetaTrader 4 → File → Open Data Folder.
3. Copy the file into `MQL4/Indicators/`.
4. Restart MetaTrader 4 (or right-click "Indicators" in the Navigator
   and choose Refresh).
5. Drag the indicator onto any chart from the Navigator panel.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `InpPeriod` | 14 | EMA smoothing period and ATR period |
| `InpThreshold` | 0.15 | Minimum VI+/VI- difference required to confirm a signal arrow |

## Disclaimer

This indicator is educational material. It is not trading advice and
does not guarantee profit. Past performance shown in any accompanying
video does not guarantee future results. Use at your own risk.

## License

MIT — see [LICENSE](LICENSE). Free to use, modify and redistribute.
If you share or modify it, please keep the credit to the original concept authors, Etienne Botes and Douglas Siepman.
