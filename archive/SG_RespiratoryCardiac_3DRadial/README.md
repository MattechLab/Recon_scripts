# Self-Gating Extraction of Respiratory and Cardiac Motion from 3D Radial GRE and bSSFP Scans

**Author:** Matteo Tagliabue  
**Update:** 19.08.2024  
**Version:** 1.0  
**Based on:** [gpuNUFFT](https://github.com/andyschwarzl/gpuNUFFT)

## Overview

This MATLAB script is designed for extracting and analyzing respiratory and cardiac motion signals from 3D radial GRE and bSSFP MRI scans. It supports both free-running and cardiac-triggered acquisition modes. The script performs data preprocessing, motion extraction, and binning of the extracted signals.

## Requirements

- MATLAB
- Data files:
  - K-space data (`kdata_raw` and `kdata_original`)
  - Density compensation data (`DensityCompen3D`)
  - Trajectory data (`Traj3D`)
  - Pulse oximeter or ECG time vector (`pmutime`)
  - Time vector (`time`)

## Data Files

Ensure the following `.mat` files are available:

- **Free Running Data:**
  - `FreeRunning/kdata_raw.mat`
  - `FreeRunning/kdata_raw_original.mat`
  - `FreeRunning/DensityCompen3D.mat`
  - `FreeRunning/Traj3D.mat`
  - `FreeRunning/pmutime.mat`
  - `FreeRunning/time.mat`

- **Cardiac Triggered Data:**
  - `CardiacTriggered/kdata_raw.mat`
  - `CardiacTriggered/kdata_raw_original.mat`
  - `CardiacTriggered/DensityCompen3D.mat`
  - `CardiacTriggered/Traj3D.mat`
  - `CardiacTriggered/time.mat`

## Parameters

- **SegmentFR:** Number of segments for free-running data (default: 24)
- **SegmentCT:** Number of segments for cardiac-triggered data (default: 23)
- **nrCardThreshold:** Number of cardiac thresholds for binning (default: 10)
- **nrRespThreshold:** Number of respiratory thresholds for binning (default: 10)

## Usage

1. **Load Data:**
   - Load k-space data, density compensation, and trajectory data for both free-running and cardiac-triggered acquisitions.

2. **Process Cardiac Signal:**
   - Extract self-gating and ECG signals.
   - Remove non-steady-state segments and apply cardiac binning.

3. **Process Breathing Signal:**
   - Extract breathing signals based on acquisition mode.
   - Remove non-steady-state segments and apply respiratory binning.

## Functions

The script utilizes the following functions:

- `mt_extractCardiacBinningInfoBandPass`
- `mt_SGPmutime`
- `mt_diffSelfvsECG`
- `mt_removeSI`
- `mt_extractCardiacBinningInfo`
- `applyCardiacBinning`
- `mt_extractionBreathingSignalCT`
- `mt_respiratory_info_extraction_BandPass`
- `mt_removeUnsteadySegments`
- `mt_applyRespiratoryBinning`

## License

This script is provided under the [MIT License](LICENSE).

## Contact

For any questions or issues, please contact Matteo Tagliabue at [matteo.tagliabue@students.unibe.ch](mailto:matteo.tagliabue@students.unibe.ch).

---

Generated with ChatGPT.
