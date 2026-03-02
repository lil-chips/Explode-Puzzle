# MarketJournal Playbook (User-specific)

> Purpose: Persist the user's preferred market-research rules so the assistant can be consistent over time.
> This is **research + journaling**, not financial advice, and not a promise of profit.

## 0) Scope & Operating Mode
- Mode: **Zero-cost** (no paid web APIs). Primary inputs are **user-provided screenshots + links**.
- Asset types covered:
  - TW stocks (primary list maintained below)
  - US: NASDAQ index (prefer ^IXIC/QQQ screenshots)
  - Crypto: BTC, ETH, ADA, SNEK (Cardano), WMTx
  - Optional: Polymarket (screenshots/links)
- No auto-trading, no wallet connections, no automated betting.

## 1) Daily Workflow (Weekdays)
### Inputs the user provides each weekday morning
- 1× NASDAQ daily chart screenshot (same platform, daily timeframe, **with volume**)
- 5× crypto daily chart screenshots (BTC/ETH/ADA/SNEK/WMTx, **with volume**)
- 3× TW stock daily chart screenshots (user chooses which 3 today, **with volume**)
- Optional: 1–3 key news links (often from X/Twitter)
- Optional: 1 Polymarket market screenshot/link

### Where screenshots can be placed
- Folder: `MarketJournal/picture/`
- User message trigger: “今天的圖放好了＋台股三檔：A/B/C”

## 2) Daily Brief Output Template
File name: `MarketJournal/daily/YYYY-MM-DD_市場簡報.md`

Sections (always in this order):
1. 總結（Summary）— 1–3 sentences
2. 事件日曆 / 重要消息（Calendar & News）— include credibility notes
3. 台股（TW Stocks）— only the 3 chosen tickers + any critical notes on watchlist
4. 美股（US: NASDAQ）
5. 加密（Crypto: BTC/ETH/ADA/SNEK/WMTx）
6. Polymarket
7. 風險管理模板提醒（Spot-only）
8. 研究紀錄（Research log）— today’s assumptions + what to validate next

Bilingual style:
- Chinese primary, key terms in English in parentheses.

## 3) Analysis Rules (Probability-first)
- Focus on **directional scenarios + probabilities**, not precise entry/exit calls.
- Always list **Key levels** (support/resistance) visible on the chart.
- Use:
  - Trend: EMA(20/50/200) if present; otherwise infer trend by structure.
  - Patterns: box range, breakout/retest, W-bottom, M-top, H&S (top/bottom).
  - Volume confirmation: breakout without volume = lower confidence.
- Output should include:
  - Scenario A (bullish) + what must be true
  - Scenario B (bearish) + what must be true
  - Confidence notes (data quality / missing indicators)

## 4) Credibility Rules (News from X/Twitter)
Rank evidence (highest → lowest):
1) Official announcements / filings / exchange notices
2) Major media with citations
3) Established analysts / KOLs
4) Unverified accounts / rumors

If a link cannot be accessed (login/paywall), request pasted text or a screenshot.

## 5) Risk Management (Spot-only, user preference)
- Default risk-per-idea guidance (user can override): 0.5%–1.5% of total capital.
- Always include: invalidation idea (what would prove the scenario wrong).
- Emphasize diversification + avoiding overconcentration.

## 6) Watchlists
### TW stock list (current)
2002 中鋼
3481 群創
1301 台塑
1101 台泥
1712 中化合成
1907 榮成
2504 國建
1802 台玻
2383 精材
2330 台積電
2308 台達電
2303 聯電
2408 南亞科
3711 瑞儀
4938 和碩
3260 威剛
2603 長榮海運

### Crypto list (current)
- BTC, ETH, ADA, SNEK, WMTx

### US (current)
- NASDAQ index (screenshots)

## 7) Weekly Review (optional, to schedule)
- Goal: evaluate what worked, what failed, and update these rules.
- Output: `MarketJournal/weekly/YYYY-Www_週報.md`
