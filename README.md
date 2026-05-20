# Speech Enhancement via Adaptive Wiener Filter

**EC-313 Digital Signal Processing — CEP** | NUST CEME, DE-45

Airport noise suppression on the NOIZEUS corpus using a two-stage Adaptive Wiener Filter + Butterworth post-filter, implemented in MATLAB.

---

## What It Does

Takes 30 phonetically balanced IEEE sentences corrupted by real airport noise at 5 dB SNR, runs them through a sliding-window Wiener filter, then cleans up the sub-400 Hz aircraft rumble with a 6th-order Butterworth high-pass filter. The result: **+1.0137 dB average Segmental SNR improvement** across all 30 utterances.

Not a revolutionary number — but at 5 dB SNR, linear Wiener filtering is close to its theoretical ceiling. The engine rumble is gone, the speaker is more intelligible, and the speech-band harmonics survive intact.

---

## Why Adaptive Wiener (not FIR/IIR)

Airport noise is non-stationary: quiet inter-arrival gaps, loud jet pushbacks, tannoy announcements, HVAC — the noise floor shifts constantly. A fixed-coefficient filter can't adapt to that. The Wiener filter re-estimates local signal statistics at every 30 ms window, so it applies more suppression when the frame is noise-dominated and backs off when speech is present.

Fixed bandpass FIR would just remove the same frequencies everywhere — no content-based selectivity. That's not useful here.

---

## Algorithm

### Stage 1 — Adaptive Wiener Filter

Sliding window of N = 240 samples (~30 ms at 8 kHz):

```
G[n] = max{ 0, (σ²_L[n] − σ²_η) / (σ²_L[n] + ε) }
ŝ[n] = μ_L[n] + G[n] · (x[n] − μ_L[n])
```

- `σ²_L[n]` — local variance within window
- `σ²_η` — noise variance estimated from first 800 background samples
- `ε` — machine epsilon (numerical stability)
- Gain floor at zero prevents signal inversion

### Stage 2 — Butterworth High-Pass Post-Filter

```matlab
[b, a] = butter(6, 400/(fs/2), 'high');
enhanced = filtfilt(b, a, wiener_output);
```

6th-order, cutoff at 400 Hz, applied with `filtfilt()` for zero-phase response. PSD analysis showed virtually all aircraft engine energy sits below 400 Hz — this stage handles it cleanly without touching the speech band (300–3400 Hz).

---

## Design Parameters

| Parameter | Value |
|---|---|
| Sampling Rate | 8000 Hz |
| Window Size | 240 samples (~30 ms) |
| Noise Variance Estimate | Mean of first 800 samples |
| Post-Filter | 6th-order Butterworth HPF |
| Cutoff Frequency | 400 Hz |
| Phase Response | Zero-phase (`filtfilt`) |
| Regularisation | `MATLAB eps` |

---

## Results

| Metric | Noisy Input | Enhanced Output |
|---|---|---|
| Segmental SNR (dB) | 5.00 | 5.4589 (+1.0137) |
| PESQ (MOS-LQO) | — | — |
| MSE (×10⁻³) | — | — |

The 1.0137 dB improvement falls within the 1.0–2.5 dB range reported by Pandey et al. (2022) for classical Wiener variants on the same NOIZEUS airport noise condition at 5 dB SNR — at the lower end, which is expected given the simpler noise estimator used here (first-800-samples vs. iterative minimum statistics).

Informal listening confirms the rumble is largely gone. A faint background hiss persists — typical of Wiener methods that deliberately avoid over-suppression.

---

## Known Limitation: Musical Noise

The main artefact is musical noise — sporadic residual peaks in unvoiced frames where local variance briefly exceeds the noise estimate, causing isolated spectral bins to survive the filter. It's audible as a faint 'twittering' in fricative frames.

Fix: replace the flat noise-floor estimate `σ²_η` with a psychoacoustic masking threshold. Upadhyay et al. (2023) show ~40% reduction in musical noise this way at negligible extra cost — directly applicable to this MATLAB implementation.

---

## Dataset

[NOIZEUS Corpus](https://ecs.utdallas.edu/loizou/speech/noizeus/) — 30 phonetically balanced IEEE sentences, 3 male + 3 female speakers, corrupted by real-world noise from the AURORA database. Airport noise condition at 5 dB SNR used exclusively.

---

## Pipeline

```
audioread()          ← load noisy .wav from Noisy/
movmean() + movvar() ← local stats (N=240)
noise variance σ²_η  ← first 800 samples
Wiener gain G[n]     ← eq. (1)
ŝ[n]                 ← eq. (2)
butter() + filtfilt() ← Butterworth HPF @ 400 Hz
audiowrite()         ← save to Enhanced/
snr() / pesq() / MSE ← evaluate
spectrogram()        ← visualise
```

---

## References

1. Y. Hu and P. C. Loizou, "Subjective evaluation and comparison of speech enhancement algorithms," *Speech Communication*, vol. 49, no. 7-8, pp. 588–601, 2007.
2. V. Pandey, R. Bhatt, and U. C. Pati, "Single-channel speech enhancement using implicit Wiener filter," *Int. J. Speech Technology*, Springer, vol. 25, pp. 689–701, 2022.
3. N. Upadhyay, A. Karmakar, and R. Bhatt, "Psychoacoustic model-driven spectral subtraction for monaural speech enhancement," *Int. J. Speech Technology*, Springer, 2023.

---

## Course Info

| | |
|---|---|
| Course | EC-313 Digital Signal Processing |
| Institution | NUST CEME, Rawalpindi |
| Batch | DE-45, Department of Computer Engineering |
| Submitted To | LE Engr. Moiz Shahid |
| Team | Abu-Bakar Chaudhary · Owais Qarni · Abdul Ahad |
| Submission Date | 5th May 2026 |
