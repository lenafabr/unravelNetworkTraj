# unravelNetworkTraj
This is an example project for the inference on diffusivity of particle dynamics on networks. Codes provided here are a direct implementation of the "unraveling" method discussed in the associated manuscript *Unraveling Single-Particle Trajectories Confined in Tubular Networks*. 
## Description
Diffusion analysis of particle dynamics on reticulated biological organelles is of great significance in the field of cellular biology as it explicates mechanisms of intracellular particle transport. The diffusivity estimation of such particle trajectories is however often complicated by the complex morphological structure of the underlying biological networks. In the manuscript *Unraveling Single-Particle Trajectories Confined in Tubular Networks*, we developed a novel method, named "unraveling", for analyzing trajectories on  networks that allows the confining geometry to be deconvolved from the particle dynamics. Here, we give a MATLAB implementation of the method and provide two main example scripts and some example experimental data for the readers to explore the method.
## Getting Started

### Dependencies

* MATLAB (version)

### Installing

* Download and uncompress, no installation needed.

### File Details

#### ```unravelNetworkTraj/networktools/```

This is a package that contains the data structure source code ```NetworkObj.m``` for our network object with some related functions. The script ```buildNetwork_example.m``` is an exmple code for constructing a triskelion network using the data structure above.

#### ```unravelNetworkTraj/code/```

This folder contains most of the source code necessary for the "unraveling" method as well as the Brownian dynamics simulation code. The "unraveling" method is implemented in the function ```unravelingInfLine.m```. The code for best diffusivity estimation is ```estimateDfromTraj_multiNT.m```. The code for Brownian simulation is ```randomWalkNetwork.m```.

### Executing program

* Direct the MATLAB "current folder" path to the ```unravelNetworkTraj/examples/``` folder.
* Run the scripts ```example_expttraj.m``` or ```example_simtraj.m``` using MATLAB.

## Authors

Elena F. Koslover, Yunhao Sun, Zexi Yu, Christopher Obara, Keshav Mittal, Jennifer Lippincott-Schwarz

## Version History

* Initial Release

## License

see the LICENSE.md file for details
