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

## 0.1) 公開資料來源清單（你手動查、丟給我整理）
下面列的都是「官方/半官方/學術常用」公開來源。你只要把你查到的 **PDF/Excel/截圖/網址** 丟給我，我就能整理成中文 docx 筆記，並把可複用框架寫回本 PLAYBOOK。

### 台灣（總體、外貿、產業）
- 財政部統計處：外貿新聞稿/簡報、稅收、綜合統計
- 財政部關務署：海關進出口統計、品項/地區、月報
- 中央銀行：利率、匯率、貨幣供給、金融統計與報告
- 行政院主計總處：GDP、CPI、國民所得、就業
- 經濟部（國際貿易署等）：貿易政策、產業資料、重點產業報告
- 證交所/櫃買：市場統計、上市櫃資料、公司公告/財報連結

### 美國（全球最常用的宏觀資料來源）
- FRED：利率/通膨/就業/金融條件等大量序列
- BEA：GDP、PCE、國民所得
- BLS：CPI、就業、薪資、PPI
- Census：零售、貿易、住房部分統計
- USTR / USITC：關稅、貿易政策/案件、貿易統計

### 國際組織（跨國一致口徑，適合比較）
- IMF（WEO/IFS）：總體、外部、財政、金融
- World Bank（WDI）：跨國發展與總體指標
- OECD：結構/政策資料（成員國更完整）
- BIS：銀行/跨境資金/信用/金融穩定
- UN Comtrade：全球貿易資料庫（品項/地區比較）

### 市場/金融（偏市場資料而非政府統計）
- 各國監管/交易所（如 SEC/EDGAR、交易所公告）：公司財報與公告
- 央行/財政部的債券拍賣與發行公告：政府債務結構/期限/成本

### 你丟給我時，最有效的格式
- PDF 簡報/報告（最好）
- Excel/CSV（數列乾淨、可做圖/計算）
- 可公開瀏覽的網頁網址
- 截圖（表格/圖表也行；解析度越高越好）

### 建議固定追的核心指標集合（快速版）
- 外貿：出口/進口年增、資通訊/電子零組件貢獻、資本設備進口
- 物價：CPI、核心 CPI
- 景氣：PMI、工業生產、零售
- 資金：政策利率、M2、信用、匯率
- 財政：赤字、債務、利息支出

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

## 4.11) Productive capacity × regional value chains lens (Southern Africa auto RVC, 2026)
From: “Productive capacity and regional value chains of the automotive sector in Southern Africa” (Cogent Economics & Finance, 2026), DOI: https://doi.org/10.1080/23322039.2026.2617689
- Productive capacity is a first-class driver of RVC depth:
  - Higher productive capacity → stronger intra-regional exports, especially **higher value Tier 1 components**.
- RVC mapping matters (tiered decomposition):
  - Distinguish Tier 1 vs Tier 2 vs Tier 3 (raw materials). Don’t call “exports” integration if it’s mostly Tier 3.
- Non-obvious trade-off:
  - Importers with rising productive capacity can become self-sufficient → intra-regional imports may fall (integration can plateau).
- Practical policy question:
  - Are we investing in capabilities that move the region up-tier (skills, manufacturing processes, standards), or just expanding extraction/inputs?

## 4.12) Trade policy instruments have limits without productivity/regulation (Kenya sugar, EAC/COMESA, 2026)
From: “The impact of the East African Community (EAC) trade policies on the performance of the sugar industry in Kenya” (Cogent Economics & Finance, 2026), DOI: https://doi.org/10.1080/23322039.2026.2614454
- Tariffs/NTBs may not move import demand directly, but they reshape *protection* metrics:
  - Track sector protection via measures like Net Protection Rate (NPR), not only import volumes.
- “Trade policy in isolation” failure mode:
  - Market integration tools without regulatory reform + efficiency investment → mixed/weak performance effects.
- Practical integration lens:
  - Sensitive staples (sugar, grains) need sequencing: productivity upgrade + governance/regulation first, then negotiate liberalization space.

## 4.13) Public debt → private investment is asymmetric (Uganda NARDL, 1990–2022)
From: “Effects of public debt on private investment in Sub–Saharan Africa empirical evidence on the uneven effects in Uganda” (Cogent Economics & Finance, 2026), DOI: https://doi.org/10.1080/23322039.2026.2614474
- Assume **nonlinearity/asymmetry** by default when debt levels are rising:
  - Rising debt can crowd out private investment differently than falling debt helps it (use NARDL-type framing).
- Separate domestic vs external debt channels:
  - Domestic borrowing is more likely to crowd out via local liquidity/interest rate pressure; external debt works through FX risk/conditionality.
- Policy mapping:
  - Borrowing composition matters as much as total: shift toward productive sectors (infrastructure/human capital) vs recurrent spending.
- Practical market question:
  - Is debt financing soaking up domestic credit that would otherwise fund private capex (watch credit growth + government securities appetite)?

## 4.14) Innovation/R&D/FDI effects are *quantile- and stage-dependent* (West Africa, 1991–2023)
From: “Technological innovation, R&D, FDI, and governance as drivers of economic growth: evidence from West African countries” (Cogent Economics & Finance, 2026), DOI: https://doi.org/10.1080/23322039.2026.2614434
- Don’t assume uniform average effects; check **heterogeneity across the growth/income distribution**:
  - Innovation (patents) and R&D can be strongly positive at higher quantiles / more advanced contexts, but weak or even negative at very low income levels.
- **Absorptive capacity is the gate** for FDI impact:
  - If infrastructure/skills/institutions are weak, FDI’s measured growth impact can be limited or fade as economies move up.
- Governance signals can be mixed/non-monotonic:
  - Governance measures may look weak or even negative in higher-performing contexts; treat governance as potentially **indirect/long-horizon** rather than a guaranteed short-run growth booster.
- Practical policy sequence:
  - Build absorptive capacity (education, infrastructure, innovation ecosystem) → then FDI + innovation variables become reliable growth engines.
- Practical market/research use:
  - When analyzing “FDI-led growth” stories, always ask: which income stage? which quantile? what’s the absorptive capacity proxy?

## 4.15) Subsidy intensity can be too small to show up in profits; separate selection bias vs true zero-effect (Burkina Faso fertilizer subsidy, 2020 survey)
From: “Effect of fertilizer subsidies on farm financial profitability in Burkina Faso” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2607204
- If a subsidy shows “no effect”, first ask: **is it under-dosed?**
  - Low subsidy rate can be statistically indistinguishable from zero impact even if the mechanism is real.
- Evaluation hygiene for policy programs:
  - Treat both **selection bias** (who receives subsidy) and **endogeneity** (subsidy correlated with unobservables) as default problems; combine tools (e.g., matching + Heckman / simultaneous equations) rather than relying on one estimator.
- Profit decomposition lens:
  - Subsidy works mainly by lowering **variable costs**; if variable costs don’t move enough, profits won’t move.
- Common correlates to watch (from this case):
  - Positive: equipment/capital, extension services, fixed-capacity factors.
  - Negative: credit access can correlate with lower profitability (often a distress/need proxy), household size, variable costs.
- Practical policy mapping:
  - If keeping the program, scale intensity and pair it with extension/capacity support; otherwise you’re subsidizing paperwork, not productivity.

## 4.16) Co-movement ≠ mechanism; treat AI investment and GDP as a feedback loop with regime breaks (USA 2012–2023, wavelets)
From: “Artificial intelligence and gross domestic product: the case of the USA” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2601923
- When studying AI investment ↔ growth, assume **two-way feedback** rather than one-direction causality:
  - Growth can induce AI investment (profit expectations/capex), and AI investment can raise growth (productivity).
- Use a **regime/break lens**:
  - Large shocks (e.g., COVID) can dominate co-movement; don’t generalize from crisis windows.
- Time-frequency tools are good for “when does the link hold?” questions:
  - Wavelet coherence/power is a fit when relationships change by period/horizon; don’t overinterpret it as structural causality.
- Practical reading rule:
  - If a paper uses coherence methods, extract: (a) which years the relationship is strong, (b) which direction leads/lag, (c) whether results persist outside shocks.

## 4.17) Sin-tax has inertia + stockpiling; index excises to inflation and enforce against illicit substitution (Jordan cigarette excise, 2008–2023)
From: “Nicotax: the fiscal and behavioural dynamics of cigarette taxation in Jordan” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2596459
- Expect a **front-loaded behavior response** to excise hikes, then partial rebound:
  - Immediate consumption drop can be followed by offsets in later quarters (inertia, stockpiling, substitution/illicit).
- Don’t do one-off hikes; do **regular, inflation-indexed** excise updates:
  - Otherwise real tax erodes and the behavior effect fades.
- Track the fiscal-health bind explicitly:
  - Revenue is often tightly tied to consumption → policymakers face a dilemma; model both consumption and revenue dynamics.
- Complementary policy is not optional:
  - Enforcement/anti-illicit measures are required so the response isn’t mostly substitution into untaxed channels.
- Practical macro lens:
  - For any sin-tax story (tobacco, alcohol, fuel), always ask: rebound/stockpiling? illicit share? inflation indexation? revenue elasticity?

## 4.18) Fragile-state macro drivers can flip sign; separate short-run shock effects vs long-run association (Somalia remittances/FDI/exports, 1991–2020)
From: “Evaluating the impact of remittance, FDI and export on economic growth of Somalia: an empirical analysis” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2593737
- In fragile/post-conflict states, standard “growth drivers” can behave nonstandard:
  - Exports can correlate negatively with growth if they reflect low value-add, concentration, or extraction.
- Expect **short-run vs long-run sign reversals** (the “FDI paradox” pattern):
  - FDI may be disruptive in the short run (institutional weakness, enclave projects), yet positive in the long run.
- Remittances as a lifeline vs development channel:
  - Remittances can boost short-run stability/consumption, but need formal channels to become productive investment.
- Practical policy translation:
  - Don’t chase FDI volume; write contracts for local jobs/value-add and manage the transition costs.
  - Diversify exports (products/markets) and move up value chain before expecting exports to be “growth positive.”
- Practical research rule:
  - When you see negative export coefficients, ask: export composition? ToT shocks? measurement of “exports” capturing smuggling/commodity cycles?

## 4.19) FDI is a labor-market lever in fragile states; treat youth unemployment as a stability variable (Sudan youth employment/peacebuilding, 1992–2023)
From: “Leveraging FDI for peacebuilding: evidence from youth employment dynamics in Sudan” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2594125
- In post-conflict contexts, map FDI → outcomes through **jobs**, not only GDP:
  - Youth unemployment is a stability/peacebuilding variable, not just an economic statistic.
- Separate horizons:
  - FDI and financial development can lower youth unemployment in the long run, while inflation can worsen it.
- Practical policy mapping:
  - “FDI attraction” should be evaluated by employability creation (training pipelines, labor absorption), not headline inflows.
- Practical macro lens:
  - If inflation is high/persistent, it can erode employability gains; treat stabilization policy as complementary to FDI-led job strategies.

## 4.20) Digital transformation attracts FDI via transaction-cost + transparency channels; components matter by partner development level (Vietnam 2007–2023 gravity)
From: “Digital transformation as a catalyst for foreign direct investment: evidence from an emerging economy” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2586304
- Treat “digital transformation” as multiple levers, not one blob:
  - e-government, digital economy, digital society can have different effects.
- Expect heterogeneity by investor origin:
  - Developed-country investors respond to broad digital improvements; developing-country investors may respond mostly to **e-government** (friction removal).
- Regulatory alignment amplifies digital effects:
  - Stronger effects with partners where standards/institutions align (e.g., EU alignment story).
- Robust proxy rule:
  - Mobile connectivity (subscriptions/usage) is often the most powerful practical proxy for “digital readiness” in emerging markets.
- Practical policy mapping:
  - Prioritize e-government + digital infrastructure first; then pursue international-standard alignment to compound FDI attractiveness.

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

## 4.15) Mobility × growth lens (education spending paper, 2025)
From: “The effects of intergenerational income mobility and per pupil education spending on economic growth” (Cogent Economics & Finance, 2025), DOI: https://doi.org/10.1080/23322039.2025.2521465
- Treat intergenerational mobility as a long-run state variable:
  - Low mobility → talent misallocation → lower potential growth.
- K-12 per-pupil spending is growth policy, not only welfare:
  - Higher spending improves absolute & relative mobility and raises attainment.
- Centralized education finance has redistribution/leveling effects:
  - Helps lower-spending regions catch up, improving long-run performance.

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
