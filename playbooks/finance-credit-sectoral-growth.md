# Playbook — Finance/Credit → Sectoral Growth (template)

Purpose: a reusable analysis template for papers / datasets studying how financial credit affects *sectoral* economic growth.

This playbook was distilled from:
- Katende, Wokadala, & Asiimwe (2026), *Does financial credit drive sectoral economic growth in Uganda? Evidence from Other Depository Corporations*, Cogent Economics & Finance. DOI: 10.1080/23322039.2026.2623341

---

## 0) Fast intake (what are we even analyzing?)

Capture in 3–6 bullets:
- Country / region:
- Periodicity + time span:
- Units (sectors? firms? regions?):
- Dependent variable (sectoral GDP/value-added/growth/employment):
- Credit variables (aggregate vs disaggregated by institution):
- Controls (lending rate, inflation, FX, etc.):

---

## 1) Always disaggregate credit by *source*

Do **not** rely only on “private sector credit” aggregate if the paper/data supports splitting by provider.

Minimum split (adapt naming to context):
- **Commercial banks** (dominant formal credit)
- **Inclusive/small deposit-taking institutions** (MDTIs/MFIs/co-ops etc.)
- **Credit institutions / other lenders** (NBFIs, consumer-credit heavy, etc.)

Outputs to produce:
- Which credit-source(s) matter?
- Which don’t?
- Are the estimated elasticities economically meaningful even if small?

---

## 2) Separate short-run vs long-run effects (don’t mix them)

Default stance from the reference paper:
- Credit may show **weak/insignificant short-run** effects.
- Credit may show **significant long-run** effects that accumulate.

When reading results:
- Extract long-run coefficients per credit source.
- Extract short-run coefficients per credit source.
- Check **error correction term (ECT)** if using ECM/ARDL form:
  - Expect ECT < 0 and significant for stable long-run relationship.
  - Interpret speed of adjustment (e.g., “~30% of disequilibrium corrected per quarter”).

---

## 3) Handle heterogeneity across sectors explicitly

Principle:
- Sectors differ in risk, formality, collateral, cashflow stability → credit transmission differs.

If the methodology allows it:
- Allow **short-run dynamics** to vary by sector.
- Test whether **long-run slopes** can be pooled across sectors.

Example workflow (as in ARDL-PMG use-cases):
- Compare PMG vs MG vs DFE (or analogous estimators).
- Use Hausman-type tests or model-selection logic to justify pooling.

---

## 4) Don’t stop at correlation — check direction (panel causality)

If data is panel:
- Use a panel Granger causality approach (e.g., Dumitrescu–Hurlin) to test whether credit predicts sectoral GDP dynamics.

Output format:
- Commercial bank credit → sectoral GDP: (yes/no; strength)
- MDTI/MFI-type credit → sectoral GDP: (yes/no)
- Credit institutions/NBFIs → sectoral GDP: (yes/no)

---

## 5) Policy translation (map results → interventions)

Avoid the naive leap:
- “Credit helps growth → cut interest rates for everyone.”

Prefer targeted levers based on which credit channels work:

If **commercial banks + inclusive deposit-takers** show long-run impact:
- Targeted concessional lending to high-potential sectors
- Credit guarantee facilities / risk-sharing mechanisms
- Sector-specific subsidies via effective channels

If a provider class is insignificant:
- Investigate reasons before recommending expansion:
  - too small scale?
  - short-tenor consumer loans?
  - regulatory constraints?
  - misallocation / weak targeting?

---

## 6) Minimum “results extraction” checklist

When summarizing any paper in this family, always extract:
- Data coverage (N sectors, T periods, frequency)
- Model family (ARDL/ECM, FE/RE, IV, GMM, PCSE, etc.)
- Long-run effects by credit source
- Short-run effects by credit source
- Controls: sign + significance (rates/inflation/FX)
- Robustness checks (alternative samples, alternative SEs, alternative estimators)
- Causality tests (if any)
- Practical interpretation (economic significance, not just p-values)

---

## 7) Common pitfalls (watchlist)

- Treating “credit” as homogeneous when provider incentives differ.
- Declaring “no effect” based on short-run insignificance alone.
- Ignoring cross-sectional dependence / common macro shocks in sector panels.
- Over-general policy recommendation that doesn’t match the identified effective channel.

---

## 8) Reusable answer skeleton (fill-in-the-blanks)

Use this to produce a clean, repeatable analysis:

1) **Question**: Does credit (by provider) drive sectoral growth, short- vs long-run?
2) **Data**: [country], [period], [units], [DV], [credit split], [controls]
3) **Method**: [dynamic panel method], handling heterogeneity via [approach]
4) **Findings**:
   - Long-run: CB credit [sign, size]; inclusive credit [sign, size]; other credit [sign/insig]
   - Short-run: [summary]
   - Adjustment (ECT): [speed]
   - Causality: [results]
5) **Implications**: targeted policy instruments aligned to effective channels
6) **Limits**: missing sector controls, informality measurement, time horizon, etc.
