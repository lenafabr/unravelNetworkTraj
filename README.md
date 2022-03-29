# unravelNetworkTraj
This is an example project for the inference of diffusivity for particle trajectories on networks. Codes provided here are a direct implementation of the "unraveling" method discussed in the associated manuscript *Unraveling Single-Particle Trajectories Confined in Tubular Networks*, by Sun et al.
## Description
Diffusion analysis of particle dynamics on reticulated biological organelles is of great significance in the field of cellular biology as it explicates mechanisms of intracellular particle transport. The diffusivity estimation of such particle trajectories is however often complicated by the complex morphological structure of the underlying biological networks. In the manuscript *Unraveling Single-Particle Trajectories Confined in Tubular Networks*, we developed a novel method for analyzing trajectories on  networks that allows the confining geometry to be deconvolved from the particle dynamics. Here, we give a MATLAB implementation of the method and provide two main example scripts and some example experimental data for readers to explore the method.
## Getting Started

### Dependencies

* MATLAB (tested on Version ???)

### Installing

* Download and uncompress, no installation needed.

### File Details

#### ```unravelNetworkTraj/networktools/```

This is a package that contains the data structure source code ```NetworkObj.m``` for our network object with some related functions. The script ```buildNetwork_example.m``` is an example code for constructing a triskelion network using the data structure above.

#### ```unravelNetworkTraj/code/```

This folder contains most of the source code necessary for the "unraveling" method as well as the Brownian dynamics simulation code. The "unraveling" method is implemented in the function ```unravelingInfLine.m```. The code for best diffusivity estimation is ```estimateDfromTraj_multiNT.m```. The code for Brownian simulation is ```randomWalkNetwork.m```.

### Executing program

* Direct the MATLAB "current folder" path to the ```unravelNetworkTraj/examples/``` folder.
* Run the scripts ```examples/example_simtraj.m``` or ```examples/example_expttraj.m``` using MATLAB.

## Example with simulated trajectories: ```example_simtraj.m```
In this file, we provide a sample script for the generation and analysis of simulated Brownian trajectories on an experimentally observed ER network. An experimentally filmed ER network recording is loaded and a network structure is extracted by skeletonizing a selected frame from the movie (line 24). Users can plot the network object over the original ER snapshot (line 26-33). We simulate the motion of an ensemble of 100 Brownian particles of diffusivity 1.5um^2/s with 10 thousand discrete time steps (line 51). The simulated trajectories can also be plotted graphically along with the network (line 59-66). We find the optimal estimated diffusivity ```Dopt``` by using the "unraveling" method (line 88) and obtain the unraveled trajectories with the optimal diffusivity (line 95-105). Users can compare the MSD of the original trajectories (line 80) and the unraveled trajectories (line 111).

## Example with experimental trajectories: ```example_expttraj.m```
In this file, we provide a sample script for the analysis of experimentally tracked Brownian trajectories on an experimentally observed ER network. An experimentally filmed ER network recording is loaded and a sequence of network structures are extracted by skeletonizing every frame from the movie (line 25-29). A set of experimentally tracked membrane protein trajectories is loaded. Users can plot the a selected network object over the corresponding, original ER snapshot along with the corresponding trajectories within a ```dframe``` interval around the selected frame (line 65-98). Then, iterating through the sequence of network structures, the trajectories that falls within a ```dframe``` interval of each snapshot is taken and projected to the network structure (line 106-138). We find the optimal estimated diffusivity ```Dopt``` by using the "unraveling" method over the whole sequence of network objects with their corresponding trajectories (line 155) and obtain the unraveled trajectories with the optimal diffusivity (line 162-172). Users can compare the MSD of the original experimental trajectories (line 147) and the unraveled trajectories (line 178).

## Authors

Yunhao Sun, Zexi Yu, Christopher Obara, Keshav Mittal, Jennifer Lippincott-Schwarz, Elena Koslover

## Version History

* Initial Release

## License

see the LICENSE.md file for details
