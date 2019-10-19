# Identifying cities using clustering

### Abstract

Classifying urban areas can be a difficult and often subjective task, relying mostly on administrative data. However, administrative boundaries are not a very accurate representation of the delineation between rural and urban areas. In this thesis a classification of land use is proposed based on a number of geographical and socio-economic variables. Dimensionality reduction and clustering algorithms are applied to high-resolution geographical and census data, to identify urban clusters based on their similarities. Thereafter, a thorough comparison of various clustering algorithms and dimensionality reduction algorithms is provided. Bath and North East Somerset county (UK) is used as a study-case dataset, but a general comparison of the readily available dimensionality reduction and clustering methods is provided. The results of this work provide new understanding of various computational methods that can be applied to the urban data, which leads to a multidisciplinary approach of defining urban/rural boundaries.

### Details of source code included

This repository includes all the R scripts I have written using clustering and dimensionality reduction methods to identify patterns in urban data. The urban data includes a range of landscape and socio-economic metrics, based on which similarities between geographical regions are identified. The data used is available from [Office for National Statistics](https://www.ons.gov.uk), but has been put together into a csv file which is also included in this repository.

The main R program allows for clustering using 5 different methods: "DIANA", "AGNES", "K-MEANS", "CLARA", "PAM". Those clustering algorithms are performed on either of the two dimensionality reduced datasets: "PCA" or "T-SNE". 

For this project mainly "Bath and North East Somerset" data was analysed, to minimise the computational resources required, however with more computational power it is possible to run the script on larger datasets (including England dataset). 

The folder called "clusterMapPlotting (Python)" includes all the Python scripts and files used for plotting the clustering patterns on the map. It also contains the clustering for the entire England dataset, the clustering algorithms for which were run on a supercomputer.

The rest of the files and folders include information and scripts written to help with the delivery of the plots in the manuscript. **The full manuscript of the dissertation is included for further details.**