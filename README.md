# Urban-rural-clustering
Includes the clustering scripts as well as plotting functionality

This repository was created to include the final codes, which I have written for my dissertation project: "Identifying Cities using clustering". It uses a range of landscape and socio-economic data, to cluster geographical regions based on their similarities. The data used is included as a csv file.

It includes R scripts which perform the clustering using 5 different methods: "DIANA", "AGNES", "K-Means", "CLARA", "PAM". Those clustering algorithms are performed on either of the two dimensinality reduced datasets: "PCA" or "t-SNE". 

For this project "Bath and North East Somerset" data only has been selected, to minimise the computational resources required, however with more computational resource it is possible to run the script on larger datasets (including England dataset).

Jupyter notebook python scripts have been included for plotting of the clustering results. A cluster map plotter for "England" datastet has also been included, for which the results were calculated on a high perormance computer.

It is not recommended to run the "Englnad" dataset on a regular computer.
