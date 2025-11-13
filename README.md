## Project Proposal: Real-Time Voice Changer

### Overview

We propose to design and implement a real-time voice-changer. The system will capture live microphone input, process it on the FPGA with a selectable chain of DSP effects (pitch shift, formant shift, robot/vocoder, delay/reverb, ect), and output the transformed audio to headphones or speakers.

This project reuses and extends concepts and modules from the existing lab 5 with the aim to produce a usable, demonstrable voice-changer.


### Objectives and Success Criteria

- Capture audio from the Pmod I2S2 (CS5343) at 48 kHz sample rate 
- Implement at least three real-time effects: pitch shifting, formant shifting (timbre control), and a robot/vocoder-like effect -- really whatever we come up with.
- Provide user controls (switches/buttons or UART/USB commands) to select effect type and parameters.

### Relevance to Existing Lab Material

The existing lab material for the Nexys A7 (Lab 5: DAC Siren) demonstrates:
- Interfacing to the Pmod I2S / Pmod I2S2 hardware.
- A `dac_if` module that serializes parallel audio words into I2S-format output.
- Simple tone-generation modules (`tone`, `wail`) and top-level wiring (`siren`).

We will reuse `dac_if.vhd` and the constraint approach in `siren.xdc`, and add an ADC receive interface (`adc_if` / `i2s_rx`), buffering, DSP blocks, and control logic.

Files and modules to examine / reuse from the repository:
- `dac_if.vhd` — I2S/DAC transmit interface (adapt to 24-bit stereo output)
- `tone.vhd`, `wail.vhd`, `siren.vhd` — examples of timing, sample-rate control, and top-level wiring
- `siren.xdc` — constraint file to adapt for Pmod I2S2 pin assignments