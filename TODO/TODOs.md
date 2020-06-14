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
- [x] Test Programs for corner cases in Operand Collector
### 2. Create Instruction Stream (in assembly) for Testing
> Tridash, Dipayan
- [x] Template content of Task Manager (SW warp ID, PC, Number of Registers, Active Mask)
- [x] Nested branches and SIMT stack testing
- [x] Memory Access, Active Mask and Instruction Replay
- [x] Nreg_TM_RAU now changed to number of pairs of registers
- [x] Shared Memory testing
- [x] Simulate Memory Unit
- [x] Create a script to initialize Task Manager in hex (two versions, one for debug, one for FileIO)
- [ ] Create an example simulation project to show students the entire workflow from initializing memory, run scripts to generate binary code and finally parse the memory dumped file into a human-readable form
- [ ] Add one section in the tutorial for Task manager initialization
- [ ] Try simulating in Modelsim/NcSim
- [ ] Confirm the actual exception and virtual memory support in AMD/Nvidia implementation
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
- [x] Test Programs for corner cases in PC/IF stage
- [x] Overall instruction to initialize I-Cache, Task Manager and Memory Unit in both simulation and implementation on FPGA
- [ ] Work with the mentors to parse the raw data for memory unit
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
- [x] Resolve issues in assembler and start simulate SIMT stack
- [x] Implementation and Deployment on FPGA Board and test with FileIO
- [ ] Add one section in the tutorial to illustrate how to write a loop program in our ISA
- [ ] Add one slide to illustrate the timing issue in the critical path from IBuffer to Operand Collector and how we fixed it
---