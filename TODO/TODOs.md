# TO-DO Tasks Tracker
> Created by Chang Xu on 04/10/2020
---
## Meeting on 04/12/2020: Project Ready for Simulation
---
### 1. Create a Generic Testbench
> Rui, Jiaming
- [ ] Initialize Task Manager, instruction memory and data memory
- [ ] Trigger Task manager to start execution
- [ ] Dump the content of RegFile and data memory
### 2. Create Instruction Stream (in assembly) for Testing
> Tridash, Dipayan
- [ ] Simple and basic ALU instruction stream
- [ ] Nested branches and SIMT stack testing
- [ ] Memory Access, Active Mask and Instruction Replay
- [ ] Shared Memory testing
- [ ] Covert some real [cuda application](../cuda) into our assembly
### 3. Verify Assembler and Reverse Assembler (much easier to verify together)
> Eda, Yang
- [ ] Link to [Assembler](https://github.com/L1ttleFlyyy/EE560-GPU-ISA-Assembler)
- [ ] Link to Reverse Assembler ([Source File to be added to project]())
- [ ] Make sure most cases are coverd: e.g. negtive immediate(signed extend), dot S instructions
### 4. Integrate FileIO and reverse assembler
> Spandan, Chang
- [ ] Inject reverse assembler (and PC) in each stage
- [ ] Complete gpu_top_with_FileIO
- [ ] Code cleanup (warning)
---