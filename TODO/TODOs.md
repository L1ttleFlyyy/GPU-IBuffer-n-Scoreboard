# TO-DO Tasks Tracker
> Created by Chang Xu on 04/10/2020
---
## Meeting on 04/12/2020: Project Ready for Simulation

## Updated on 04/18/2020

## Updated on 05/09/2020: Simulation and documentation

---
<span style="color:green">Each team should have their slides revised by May 24</span>

<span style="color:yellow">Each team come up with a test instruction stream for corner cases</span>

<span style="color:blue">Each team should make introduction video for their slides</span>


### 1. Create a Generic Testbench

> Rui, Jiaming
- [x] Initialize Task Manager, instruction memory and data memory
- [x] Trigger Task manager to start execution
- [x] Dump the content of RegFile and data memory
- [x] Nreg_TM_RAU now changed to number of pairs of registers
- [x] Covert real [cuda application](../cuda/add.cu) into our assembly
- [x] Serialization program adding up 1024 numbers (asm & cuda)
- [x] Initialize the RF using mem init file
- [x] Create project and debug Operand Collector
### 2. Create Instruction Stream (in assembly) for Testing
> Tridash, Dipayan
- [x] Template content of Task Manager (SW warp ID, PC, Number of Registers, Active Mask)
- [x] Nested branches and SIMT stack testing
- [x] Memory Access, Active Mask and Instruction Replay
- [x] Nreg_TM_RAU now changed to number of pairs of registers
- [x] Shared Memory testing
- [ ] Simulate Memory Unit
- [ ] Try simulating in Modelsim/NcSim
- [ ] Create a script to initialize Task Manager in hex (two versions, one for debug, one for FileIO)
- [ ] Confirm the actual exception and virtual memory support in AMD/Nvidia implementation
- [ ] Figure out how cudaMalloc pointer is translated to actual GPU memory location
### 3. Verify Assembler and Reverse Assembler (much easier to verify together)
> Eda, Yang
- [x] Simple and basic ALU instruction stream</span>
- [x] Link to [Assembler](https://github.com/L1ttleFlyyy/EE560-GPU-ISA-Assembler)
- [x] Link to Reverse Assembler ([Source File to be added to project]())
- [x] A simple testbench utilizing the reverse assembler to disassmble instructions
- [x] Post-Synth of multiplier
- [x] Modify assembler
- [x] ISA modification (LD => LW), documentaion, assembler, reverse assembler
- [x] Fix casez in ALUop generation logic
- [x] Covert real [cuda application](../cuda/mulv.cu) into our assembly
- [x] CUDA simulator / (HPC platform)
### 4. Integrate FileIO and reverse assembler
> Spandan, Chang
- [x] Inject reverse assembler (and PC) in each stage
- [x] Clock counter injection
- [x] Code cleanup (warnings)
- [x] Constraint file for implementation
- [x] Reduce clock frequency to 50Mhz using Clock Wizard
- [x] Complete gpu_top_with_FileIO
- [x] Verify FileIO reading/writing on board
- [x] Create waveform configurations for each team and dipatch the projects
- [x] Create a general overall introduction slides to our GPU design
- [ ] Resolve issues in assembler and start simulate SIMT stack
---