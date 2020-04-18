# TO-DO Tasks Tracker
> Created by Chang Xu on 04/10/2020
---
## Meeting on 04/12/2020: Project Ready for Simulation

## Updated on 04/18/2020

---
<span style="color:yellow">Each team come up with a test instruction stream for corner cases</span>

### 1. <span style="color:yellow">Create a Generic Testbench</span>

> Rui, Jiaming
- [x] Initialize Task Manager, instruction memory and data memory
- [x] Trigger Task manager to start execution
- [x] Dump the content of RegFile and data memory
- [ ] Nreg_TM_RAU now changed to number of pairs of registers
### 2. Create Instruction Stream (in assembly) for Testing
> Tridash, Dipayan
- [x] <span style="color:yellow">Content of Task Manager (SW warp ID, PC, Number of Registers, Active Mask)</span>
- [x] <span style="color:yellow">Nested branches and SIMT stack testing</span>
- [ ] Memory Access, Active Mask and Instruction Replay
- [ ] Shared Memory testing
- [ ] Covert some real [cuda application](../cuda) into our assembly
- [ ] Nreg_TM_RAU now changed to number of pairs of registers
### 3. Verify Assembler and Reverse Assembler (much easier to verify together)
> Eda, Yang
- [x] <span style="color:yellow">Simple and basic ALU instruction stream</span>
- [x] <span style="color:yellow">Link to [Assembler](https://github.com/L1ttleFlyyy/EE560-GPU-ISA-Assembler)</span>
- [x] <span style="color:yellow">Link to Reverse Assembler ([Source File to be added to project]())</span>
- [x] A simple testbench utilizing the reverse assembler to disassmble instructions
- [x] Post-Synth of multiplier
- [ ] Modify assembler
### 4. Integrate FileIO and reverse assembler
> Spandan, Chang
- [ ] Inject reverse assembler (and PC) in each stage
- [x] Clock counter injection
- [ ] Complete gpu_top_with_FileIO
- [x] Code cleanup (warnings)
---