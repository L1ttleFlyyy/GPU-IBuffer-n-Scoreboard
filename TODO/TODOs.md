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
- [x] Nreg_TM_RAU now changed to number of pairs of registers
- [ ] Create project and simulate
- [ ] Serialization program adding up 1024 numbers (asm & cuda)
- [ ] Covert real [cuda application](../cuda/add.cu) into our assembly
### 2. Create Instruction Stream (in assembly) for Testing
> Tridash, Dipayan
- [x] <span style="color:yellow"> Template content of Task Manager (SW warp ID, PC, Number of Registers, Active Mask)</span>
- [x] <span style="color:yellow">Nested branches and SIMT stack testing</span>
- [x] Memory Access, Active Mask and Instruction Replay
- [x] Nreg_TM_RAU now changed to number of pairs of registers
- [ ] Shared Memory testing
### 3. Verify Assembler and Reverse Assembler (much easier to verify together)
> Eda, Yang
- [x] <span style="color:yellow">Simple and basic ALU instruction stream</span>
- [x] <span style="color:yellow">Link to [Assembler](https://github.com/L1ttleFlyyy/EE560-GPU-ISA-Assembler)</span>
- [x] <span style="color:yellow">Link to Reverse Assembler ([Source File to be added to project]())</span>
- [x] A simple testbench utilizing the reverse assembler to disassmble instructions
- [x] Post-Synth of multiplier
- [x] Modify assembler
- [ ] CUDA simulator / (HPC platform)
- [ ] ISA modification (LD => LW), documentaion, assembler, reverse assembler
- [ ] Covert real [cuda application](../cuda/mulv.cu) into our assembly
### 4. Integrate FileIO and reverse assembler
> Spandan, Chang
- [x] Inject reverse assembler (and PC) in each stage
- [x] Clock counter injection
- [x] Code cleanup (warnings)
- [x] Constraint file for implementation
- [ ] Reduce clock frequency to 50Mhz using Clock Wizard
- [ ] Complete gpu_top_with_FileIO
- [ ] Verify FileIO reading/writing on board 
---