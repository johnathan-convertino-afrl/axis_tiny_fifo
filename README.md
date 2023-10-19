# AXIS TINY FIFO
### Simple single clock fifo
---

   author: Jay Convertino   
   
   date: 2021.06.02  
   
   details: Simple axis single clock pipeline fifo.  
   
   license: MIT   
   
---

### Version
#### Current
  - V1.0.0 - initial release

#### Previous
  - none

### Dependencies
#### Build
  - AFRL:utility:helper:1.0.0
  
#### Simulation
  - AFRL:simulation:axis_stimulator
  - AFRL:simulation:clock_stimulator
  - AFRL:utility:sim_helper

### IP USAGE
#### INSTRUCTIONS

Pipeline method axis fifo. This fifo uses a pipeline to create a fifo. Meaning  
it has a latency the size of the depth. If the output receiving core is not ready  
the core will build up data till it is full. All data will have a latency of the depth.   

#### PARAMETERS
* FIFO_DEPTH : DEFAULT = 4 : Set the depth of the single clock fifo (number of words the size of width).
* BUS_WIDTH  : DEFAULT = 8 : Set the data width of the fifo in bytes.

### COMPONENTS
#### SRC

* axis_tiny_fifo.v
  
#### TB

* tb_fifo.v
  
### fusesoc

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core. Verification added.

#### TARGETS

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - sim
  - sim_rand_data
  - sim_rand_ready_rand_data
  - sim_8bit_count_data
  - sim_rand_ready_8bit_count_data
