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
File name: `MarketJournal/daily/YYYY-MM-DD_市場簡報.docx`

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

## 4.1) Polymarket rules capture (market-specific)
When analyzing a Polymarket market, always capture:
- What exactly resolves YES/NO (verbatim rule summary)
- Resolution source (e.g., official sources consensus)
- Edge cases (e.g., nominee replacement does/does not change resolution)

Current tracked market:
- Democratic presidential nominee 2028
  - URL: https://polymarket.com/zh/event/democratic-presidential-nominee-2028
  - Resolves YES if the named individual **wins and accepts** the 2028 Democratic Party nomination for U.S. president.
  - Resolution source: consensus of **official Democratic Party sources**.
  - Edge case: replacement of the nominee before election day **does not change** resolution.

## 4.2) Core market-research principle (Grossman–Stiglitz 1980)
- If information is costly, markets cannot be perfectly informationally efficient.
- Practical implication for our workflow:
  - Seek small, repeatable edges (edge) rather than “perfect prediction”.
  - Treat research time as an investment; convert insights into checklists.
  - Expect edge to shrink when information becomes crowded.

## 4.3) Signal-combination research checklist (RL × TA paper, 2025)
From: “Reinforcement learning meets technical analysis: combining moving average rules for optimal alpha” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2490818
- Start from signal usefulness:
  - Verify at least some individual signals have edge in the target market; otherwise combinations amplify noise.
- Fight data mining / overfitting:
  - Strict train/validation/test split; record all tuning decisions.
  - Prefer simpler policies + regularization + early stopping.
- Separate alpha from underlying beta:
  - Avoid mistaking buy-and-hold exposure for alpha; consider market-neutral / zero-arbitrage framing.
- Costs & tradability:
  - Always stress-test transaction costs and liquidity assumptions.
- Robustness:
  - Re-test on alternative samples, proxies, or cost assumptions; don’t accept a single backtest.

## 4.4) Macroprudential × monetary policy lens (repo-rate paper, 2026)
From: “The effect of macroprudential indicators on the repo rate: Evidence from South Africa” (Cogent Economics & Finance, 2026), DOI: https://doi.org/10.1080/23322039.2026.2616509
- Central bank reaction function ≠ inflation-only:
  - In emerging/high-volatility contexts, policy rates can respond to systemic-risk indicators (e.g., DTI, CAR, NPLs, credit conditions).
- Two-tool coordination frame:
  - Rate policy mainly targets inflation/demand; macroprudential tools target leverage/systemic risk.
- Practical analysis questions when reading “hawkish/dovish” signals:
  - Are households over-levered (DTI)?
  - Are banks well-capitalized (CAR)?
  - Is credit growth overheating or tightening?
- Research hygiene:
  - Check integration order I(0)/I(1) → cointegration → long-run vs short-run.
  - Watch multicollinearity (VIF) when mixing many macro-financial indicators.

## 4.5) Fiscal capacity × structural transformation lens (SSA panel paper, 2025)
From: “Fiscal revenue mobilization and structural transformation in Sub-Saharan Africa: a panel data analysis” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2611621
- Treat fiscal capacity (revenue-to-GDP) as a state variable for long-run development:
  - It finances infrastructure, human capital, and institutions that enable diversification.
- Governance is a multiplier (mechanism):
  - Revenue → better control of corruption + political stability → stronger structural transformation.
- Practical country/region analysis questions:
  - Is revenue mobilization improving or deteriorating?
  - Are institutions stable enough for productive public investment?
- Panel-study hygiene:
  - Watch endogeneity (use IV strategies) and cross-sectional dependence (robust SE like Driscoll–Kraay).

## 4.6) Global uncertainty × small open economy lens (Nepal ARDL paper, 2025)
From: “Monetary policy and global uncertainty in a small open economy: an ARDL evidence with structural breaks in Nepal” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2610558
- External uncertainty is a state variable:
  - It can directly slow growth and weaken monetary transmission.
- Breaks/regime shifts must be modeled:
  - Use break dummies / regime interactions when shocks (pandemic, disasters, blockades) change transmission.
- Practical policy/market questions:
  - Is uncertainty spiking? Are FX regime constraints tightening? Are reserves/liquidity tools losing effectiveness?
- ECM interpretation hygiene:
  - If adjustment speed is very strong (< -1), expect short-run oscillations; interpret carefully.

## 4.7) External-balance constraint lens (CAB × growth paper, 2025)
From: “An empirical investigation of current account balance and economic growth in Sierra Leone: evidence from GARCH-model and VEC-model” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2599566
- External balance can be a hard long-run growth constraint:
  - Persistent CAB imbalances + FX volatility can cap growth.
- Volatility persistence matters:
  - If FX volatility is near-IGARCH (α+β≈1), shocks decay slowly; focus on reducing vulnerability, not just short-term stabilization.
- ToT as a long-run driver:
  - Terms-of-trade improvements may be one of the few persistent positive growth channels; use good ToT periods to invest in diversification.
- Short-run vs long-run policy split:
  - Slow ECM adjustment implies structural reforms matter more than temporary stimulus.

## 4.8) Money supply composition × credit-growth lens (Tanzania ARDL+Granger paper, 2025)
From: “Monetary aggregates and private sector credit growth in Tanzania: a causality and elasticity analysis” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2596196
- Separate “short-run leading” vs “long-run structural” effects:
  - NM/BM can lead credit in the short run (Granger), while EBM can have the strongest long-run elasticity.
- Read money as layers:
  - NM/BM = near-term liquidity pulse; EBM = financial depth (incl. institutional/FX deposits).
- Endogeneity feedback matters:
  - Credit can Granger-cause NM; monitor credit growth as a driver of transactional liquidity.
- Policy framing:
  - Manage both immediate liquidity (NM/BM) and long-run deposit depth (BM/EBM), plus macroprudential oversight.

## 4.9) Fiscal space erosion lens (WAEMU paper, 2025)
From: “Determinants of the fiscal space of WAEMU member countries” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2584517
- Fiscal space is often killed by rigid spending:
  - Wage bill, debt service, military spending, and (inefficient) capital spending can structurally shrink room to maneuver.
- In monetary unions, fiscal space is the key stabilization capacity:
  - With limited independent monetary policy, fiscal rules + debt dynamics make fiscal space a primary risk variable.
- Practical analysis questions:
  - What share of spending is rigid (wages/interest/security)?
  - Is capex productive or leak-prone (governance)?
- Policy order:
  - Control rigid spending + improve governance → then expand tax base so new revenue becomes development investment.

## 4.10) Probabilistic debt sustainability lens (Euro Area paper, 2025)
From: “Sovereign debt sustainability in the Euro Area: a probabilistic assessment” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2584593
- Treat sustainability as a probability distribution, not a single threshold:
  - Use simulations of joint fiscal–macro dynamics (growth, interest rates, primary balances).
- Two archetypes of sustainability:
  - “r−g-supported” sustainability (vulnerable to rate shocks)
  - “surplus-supported” sustainability (driven by future primary surpluses)
- Practical risk question:
  - Is a country ‘living off low rates’ or ‘living off surpluses’?

## 4.11) Domestic borrowing crowding-out lens (Tanzania paper, 2025)
From: “Fiscal operations and treasury bonds: is Tanzania experiencing investment crowding out?” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2582893
- Crowding-out mechanism (bank-dominated markets):
  - Government bond issuance can attract bank balance sheets away from private lending.
- Coordination lens:
  - Monetary easing can be offset by fiscal absorption of liquidity via domestic borrowing.
- Practical macro question:
  - Is private credit weakening while domestic government borrowing is accelerating?
- Structural vs cyclical:
  - In shallow markets, crowding-out can be a long-run structural drag, not just a short-run rate effect.

## 4.12) LDR rule design × deposit-maturity lens (Saudi paper, 2025)
From: “Loan-to-deposit reform and deposit maturity: evidence from Saudi Arabia” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2562344
- LDR is not just a ratio; it is an incentive system:
  - By assigning higher weights to longer-maturity deposits, regulators can steer banks toward more stable funding.
- Expect time-to-effect:
  - Short-run impact may be weak/transitionary; long-run interaction (policy × stable deposits) can be the real channel.
- Practical bank-stability question:
  - Is lending growth funded by stable deposits (time/savings) or by volatile short-term funding?

## 4.13) Nonlinear debt “safe zone” lens (Tanzania TVAR paper, 2025)
From: “Public debt sustainability in Tanzania: a non-linear analysis of fiscal and monetary policy interactions” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2554299
- Debt is regime-dependent (threshold effects):
  - Below a threshold, debt can support growth; above it, debt becomes a macro instability amplifier.
- High-debt regime risks:
  - Higher inflation, depreciation, higher rates, slower GDP growth.
- Policy interaction lens:
  - High debt can weaken monetary policy effectiveness (fiscal dominance risk).
- External shock amplification:
  - Oil/FX shocks hurt more in high-debt regimes.

## 4.14) Regime-dependent fiscal effectiveness lens (Central Europe MSVAR paper, 2025)
From: “Fiscal policy and household savings in Central Europe: a Markov switching VAR with covid shock” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2537233
- Fiscal multipliers are regime-dependent:
  - Initial shock vs peak crisis vs recovery can show different effects.
- MPC vs IMPC split:
  - Transfers/subsidies may raise IMPC (future smoothing) while lowering MPC (immediate spending).
- Credibility matters:
  - The same debt/spending can support consumption in one country but depress it in another if sustainability/trust differs.

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
8454 富邦媒
2377 微星

### 2002 中鋼（波段型）— personal playbook
- One-line rule（口訣）:
  - 買在盤整下緣/均線支撐帶（19～20），賣在長均線壓力帶（23～25），大行情才看 30+（但那是循環行情，不是常態）。
- How to use:
  - Treat 19–20 as the primary accumulation/support zone when structure is intact.
  - Treat 23–25 as the primary distribution/resistance zone.
  - Only consider 30+ scenarios when there is clear macro/industry-cycle confirmation (not the base case).

### Crypto list (current)
- BTC, ETH, ADA, SNEK, WMTx

### US (current)
- NASDAQ index (screenshots)

## 7) Weekly Review (optional, to schedule)
- Goal: evaluate what worked, what failed, and update these rules.
- Output: `MarketJournal/weekly/YYYY-Www_週報.md`
