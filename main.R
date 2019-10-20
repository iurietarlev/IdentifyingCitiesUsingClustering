#LIBRARIES USED IN THIS SCRIPT
library(ggplot2)      #used for ggplot
library(ggpubr)       #used for ggarrange
library(factoextra)   #used for eclust function
require(gridExtra)    #used for grid.arrange

library(RColorBrewer) #used for color palettes for ggplot

library(Rtsne)        #used for t-SNE algorithm
library(ggthemr)      #theme for plotting in ggplot


# ------ SET CURRENT WORKING DIRECTORY (RStudio) ------ #
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()




# --- IMPORTING ALL THE NECESSARY FUNCTIONS CREATED IN ANOTHER FILE --- #
source("./mainFunctions.R")

# --- RUNNING SCRIPT --- #


# change seed_no for possiility of reproducing same experiment
seed_number <- 600


region_analysed = "Bath and North East Somerset"
df_selection <- region_selector(region_analysed)

# pca transformed dataset
pca_df <-pca_transform(df_selection, region_analysed, 6, full_name =FALSE)

# t-SNE transformed dataset
tsne_df <- tsne_transform(df_selection, region_analysed, perplexity = 10, max_iter = 10000, seed = 600,
                          full_name = FALSE)

# --- CLUSTERING ANALYSIS --- #

# --- Plotting of Silhouettes --- #
direction <- sprintf("./%s_CLUST_OUTPUTS", region_analysed)
dir.create(file.path(direction), showWarnings = FALSE) 

# get the silhouette coefficients for both datasets for various clustering algos
PCA_silhouettes <- silhouettes(pca_df, 2, 20)
TSNE_silhouettes <- silhouettes(tsne_df, 2, 20)


# plot the silhouette coefficients against no of clusters and with clustering types
plot_silhouettes(PCA_silhouettes, TSNE_silhouettes, "Set1", axis_text_size = 10,
                 legend_text_size = 10, title_size = 10, aspect_ratio = 1, "Number of Clusters", "Silhouette Coefficient", 
                 point_size = 0.65,
                 heightx = 84, widthx = 150)



# create  a directory for exporting of rds files with clustering info
rds_direction <- sprintf("./%s_RDS_CLUST_DF_OUTPUTS", region_analysed)
dir.create(file.path(rds_direction), showWarnings = FALSE) 


# --- PLOTTING PCA SIL & CLUST PLOTS --- #
# change geom_type to "text" if the last 4 digits of LA_CODE need to be retained
clust_sil_plots(pca_df, 6, "PCA", direction, geom_type = "point", 
                axis_text_size = 10, legend_text_size = 9, title_size = 10,
                label_size = 5, point_size = 0.3, leg_size = 10, leg_width = 10, 
                plot_width = 150, plot_height = 240)

# --- PLOTTING tSNE SIL & CLUST PLOTS --- #
# change geom_type to "text" if the last 4 digits of LA_CODE need to be retained
clust_sil_plots(tsne_df, 6, "t-SNE", direction, geom_type = "point", 
                axis_text_size = 10, legend_text_size = 9, title_size = 10,
                label_size = 5, point_size = 0.3, leg_size = 10, leg_width = 10,
                plot_width = 150, plot_height = 240)



#=============================================================================================================#
#------------------ DOCUMENT THE CLUSTERING INTO A RDS and CSV FOR MAP PLOTTING ------------------------------
#=============================================================================================================#

pca_df_plot <-pca_transform(df_selection, region_analysed, 6, full_name =TRUE)

tsne_df_plot <- tsne_transform(df_selection, region_analysed, perplexity = 10, max_iter = 10000, seed = 600,
                          full_name = TRUE)

save_df_to_rds(tsne_df_plot,6, "tSNE", rds_direction)
save_df_to_rds(pca_df_plot, 6, "PCA", rds_direction)

csv_direction <- sprintf("./%s_CSV_FOR_PLOTTING_CLUST_OUTPUTS", region_analysed)
dir.create(file.path(csv_direction), showWarnings = FALSE) 

#------------------KMEANS_PAM_CLARA  --------------------------------------------

save_csv_for_plotting_partitional("PCA", nclust = 6, rds_direction, csv_direction)
save_csv_for_plotting_partitional("tSNE", nclust = 6, rds_direction, csv_direction)



#------------------AGNES & DIANA -------------------------------------------

save_csv_for_plotting_hierarchical("PCA", 6, rds_dir = rds_direction, csv_dir = csv_direction)
save_csv_for_plotting_hierarchical("tSNE", 6, rds_dir = rds_direction, csv_dir = csv_direction)






