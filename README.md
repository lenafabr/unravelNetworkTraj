# unravelNetworkTraj
This project provides code for the inference of diffusivity from trajectories of particles confined on network structures. Codes provided here are a direct implementation of the "unraveling" method discussed in the associated manuscript *Unraveling Single-Particle Trajectories Confined in Tubular Networks*, by Sun et al.
## Description
Diffusion analysis of particle dynamics on reticulated biological organelles is of great significance in the field of cellular biology as it explicates mechanisms of intracellular particle transport. The diffusivity estimation of such particle trajectories is however often complicated by the complex morphological structure of the underlying biological networks. In the manuscript *Unraveling Single-Particle Trajectories Confined in Tubular Networks*, we developed a novel method for analyzing trajectories on  networks that allows the confining geometry to be deconvolved from the particle dynamics. Here, we give a MATLAB implementation of the method and provide two main example scripts and some example experimental data for readers to explore the method.

## Getting Started

### Dependencies

* MATLAB (tested on Version 2021a)

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
In this file, we provide a sample script for the generation and analysis of simulated Brownian trajectories on an experimentally observed ER network. Imaging data for an ER network is loaded and a network structure is extracted by skeletonizing a selected frame from the movie. Users can plot the network object over the original ER snapshot. We simulate the motion of an ensemble of 100 Brownian particles of diffusivity 1.5um^2/s with 10 thousand discrete time steps. The simulated trajectories can also be plotted graphically along with the network. We find the optimal estimated diffusivity ```Dopt``` by using the "unraveling" method and obtain the unraveled trajectories with the estimated diffusivity. Users can compare the MSD of the original trajectories  and the unraveled trajectories.

## Example with experimental trajectories: ```example_expttraj.m```
In this file, we provide a sample script for the analysis of experimentally tracked Brownian trajectories on an experimentally observed ER network. An experimentally imaged ER network recording at ~100Hz is loaded and a sequence of network structures are extracted by skeletonizing every 100th frame from the movie. A set of experimentally tracked membrane protein trajectories is loaded. Users can plot the a selected network object over the corresponding, original ER snapshot along with the corresponding trajectories within a ```dframe``` interval around the selected frame. Then, iterating through the sequence of network structures, the trajectories that falls within a ```dframe``` interval of each snapshot is taken and projected to the network structure. We find the  estimated diffusivity ```Dopt``` by using the "unraveling" method over the whole sequence of network objects with their corresponding trajectories and obtain the unraveled trajectories with the optimal diffusivity. Users can compare the MSD of the original experimental trajectories and the unraveled trajectories.

## Manuscript Authors

Yunhao Sun, Zexi Yu, Christopher Obara, Keshav Mittal, Jennifer Lippincott-Schwarz, Elena Koslover

## Version History

* Initial Release

## License

see the LICENSE.md file for details
