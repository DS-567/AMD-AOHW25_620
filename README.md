# *From Brain-Inspiration to Silicon-Realisation:* SNN-based Smart Watchdogs for RISC-V Fault Detection

Team number: **AMD-AOHW25_620**

*Contribution to the AMD Open Hardware Design Competition 2025: Spiking Neural Network (SNN)-based Smart Watchdogs for RISC-V Fault Detection*. This repository contains a complete prototype demonstrator of the smart watchdog with supporting documentation.

See the [report](/Report/) or the [publications](#6-publications-) for more details on the project. 

## Project Overview

With the complexity and miniscule feature sizes of modern processor architectures, temporary faults as a result of manufacturing defects and radiation-induced soft errors pose serious reliability concerns for CPUs deployed in safety-critical embedded applications. Fault detection mechanisms are required to monitor and detect faults to ensure hardware integrity. 

This project developed the first brain-inspired SNN-based ***smart watchdog***, capable of real-time monitoring and fault detection in embedded processors, inspired by desirable traits of the biological brain, such as *efficiency* and *dependability*. The smart watchdog was implemented on AMD FPGAs and validated with a real-world RISC-V processor, highlighting the effectiveness of AMD FPGA platforms for research applications.

<p align="center">
  <img src="assets/smart_watchdog_concept.PNG" alt="Smart Watchdog Concept" width="400"/>
</p>

---

## Table of Contents

[1. Motivation 🧠](#1-motivation-)

[2. Methodology ⚙️](#2-methodology-)

[3. FPGA Implementation 💻](#3-fpga-implementation-)

[4. Builds 🚀](#4-builds-)

[5. Contributors 🤝](#5-contributors-)

[6. Publications 📃](#6-publications-)

[7. Acknowledgements ✨](#7-acknowledgements-)

---

## 1. Motivation 🧠

- A watchdog should provide:
   -    ***Minimal power and area overheads***
   -    ***Effective fault detection***
   -    ***Robustness to failure***

- The human brain showcases:
   -    ***Efficient computation***
   -    ***Complex learning***
   -    ***Self-repairing capability***

- Spiking Neural Networks (SNNs):
   -    Capture ***human brain dynamics*** most closely
   -    Offer more ***efficient*** and ***hardware-friendly computing***
   -    Realize ***self-repair*** via neuro-glial integration (astrocytes)
   -    Could form the basis of a novel, smarter watchdog mechanism!

**This PhD project aims to evaluate the effectiveness of SNNs for fault detection in a RISC-V processor architecture, with the objective of realising an efficient, but also more reliable watchdog circuit.**

---

## 2. Methodology ⚙️

A full ML workflow was developed from scratch in the PhD:
- Custom data collection hardware architecture created to gather training data
- Custom feature extraction algorithm
- SNN model trained using SNNTorch (~98% accuracy)
- Implemented the SNN model in VHDL and instantiated inside the smart watchdog
- Validated the smart watchdog concept on FPGA (retained ~98% accuracy)
- Created a final demonstrator of the smart watchdog on FPGA

<p align="center">
  <img src="assets/methodology.PNG" alt="Methodology" width="600"/>
</p>

---

## 3. FPGA Implementation 💻

Some text here...

---

## 4. Builds 🚀

1. Smart Watchdog Demonstrator

   - Include links to youtibe videos of the demo

---

## 5. Contributors 🤝

This work was conducted solely as part of a funded PhD project by ***David Simpson*** at [Ulster University - School of Computing, Engineering and Intelligent Systems](https://www.ulster.ac.uk/faculties/computing-engineering-and-the-built-environment/computing-engineering-intelligent-systems).

Email: simpson-d12@ulster.ac.uk 

LinkedIn: https://www.linkedin.com/in/david-simpson-040189221/

---

## 6. Publications 📃

- **ISCAS 2025 conference paper:**

    *D. Simpson, J. Harkin, M. McElholm, and L. McDaid, “Smart Watchdog Mechanism for Fault Detection in RISC-V,” in 2025 IEEE International Symposium on Circuits and Systems (ISCAS), IEEE, May 2025, pp. 1–5. doi: 10.1109/ISCAS56072.2025.11044018.*

- **ISCAS 2025 live demonstrator paper:**

    *D. Simpson, J. Harkin, M. McElholm, and L. McDaid, “Live Demonstration: Smart Watchdog Mechanism for Real-time Fault Detection in RISC-V,” in 2025 IEEE International Symposium on Circuits and Systems (ISCAS), IEEE, May 2025, pp. 1–1. doi: 10.1109/ISCAS56072.2025.11044164.*

- **TCAS II: Express Briefs journal paper (Open Access):**

    *D. Simpson, J. Harkin, M. McElholm, and L. McDaid, “Smart Watchdog for RISC-V: A Novel Spiking Neural Network Approach to Fault Detection,” IEEE Transactions on Circuits and Systems II: Express Briefs, pp. 1–1, 2025, doi: 10.1109/TCSII.2025.3583042.*

## 7. Acknowledgements ✨

- This project was funded by a Department for the Economy (DfE) PhD scholarship.

- Special thanks to Stephan Nolting (Neorv32 creator).
