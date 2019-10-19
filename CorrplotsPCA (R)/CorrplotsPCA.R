# This program creates correlation plots between different variables
# as result of Principal Component Analysis
# cos2 and contribution facotr maps are created using PCA dims

# Author: Iurie Tarlev
# Date: 10/03/2019

# ------ LOAD REQUIRED LIBRARIES ------ #
library(factoextra)
library(corrplot)
library(ggplot2)
library(FactoMineR)
library(ggcorrplot)

# ------ SET CURRENT WORKING DIRECTORY (RStudio) ------ #
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()



#---------------------------------- READ ORIGINAL CSV DATA ------------------------------#

#____read original data with set parameters
df_original <- read.csv("../stat_lsoa_england_urban_form_original_data.csv")

# -------------------------- SPECIFY WHICH REGION TO ANALYSE -----------------------------------#

# comment which region is analysed even if entire dataset
# this is used in naming of the files
region_analysed = "Bath and North East Somerset" #"South West"

# uncomment the next line if analysing entire dataset
# df_selection = df_original

# uncomment next line if analysing a certain region
# mask = df_original$REGION_NAME==region_analysed

# uncomment next line if analysing a certain subregion
mask = df_original$LA_NAME==region_analysed

#----------------------------------FORMATTING THE DATA INTO A DF------------------------------#
df_selection <- df_original[which(mask), ] # only select data for relevant region

# set variable names to the LSOA names of the area selected
names <- df_selection$LSOA_NAME





#----------------------------------PCA ALGORITHM--------------------------------------------#

# extract only parameter (numeric) columns for PCA
df <- data.frame(df_selection[,5:36])


res.pca <- PCA(df, scale.unit = TRUE, ncp = 10, graph = FALSE)

var <- get_pca_var(res.pca)


var_names <- list("Perimeter", "Area", "Domestic buildings area", "Road area",
"Road length", "Road length density", "Rail area", "Built-up area",
"Built-up propoprtion", "Buildings area", "Buildings area proportion",
"Non-built-up area", "Non-built-up area proportion", "Proportion of detached dwellings",
"Proportion of semidetached dwellings", "Green space",
"Resident population", "Male resident population", "Population density",
"Population density in built-up area", "Number of dwellings", "Density of dwellings",
"Number of household spaces", "Density of household spaces",
"Density of household spaces in built-up area", "Private car availability",
"Proportion of population with higher education",
"Proportion of population in employment", "Proportion of population employed in services",
"Proportion of flats in commercial buildings",
"Ratio of detached houses",
"Yearly household income")


# ------- PRODUCE COLUMN NAMES ------ #
datalist = list()
for (i in 1:10) {
# ... make some data
dat <- sprintf("PC %i", i)
datalist[[i]] <- dat 
}


# ------ SET PLOTTING PARAMETERS ------ #
leg_size = 10
leg_width = 40
legend_text_size = 25
plot_width = 300
plot_height = 320




#------------- COS2 CORRPLOT ------------------------#
cos2 <- var$cos2
colnames(cos2) = datalist
rownames(cos2) <- var_names
cos2_t <- t(cos2) * 100 #convert cos2 into a percentage rather than decimals

c1 <- ggcorrplot(cos2_t, method = "circle", tl.srt = 60, tl.cex = 25, tl.col = "black", legend.title = "%") +
  scale_fill_gradient2(limit = c(min(cos2_t)-0.05, max(cos2_t)+0.05), low = "white", high = "red", 
                     mid = "orange", midpoint = (min(cos2_t) + max(cos2_t))/2) +
  labs(fill = "%") + 
  theme(text = element_text(size = legend_text_size), legend.position="top",
        legend.key.size = unit(leg_size, "pt"),
        legend.key.width = unit(leg_width, "pt"),
        legend.text=element_text(size=legend_text_size, margin = margin(t = 0)))


ggsave(filename = "ggcorrplot_cos2.pdf", plot = c1, width = plot_width, height = plot_height, units = "mm")


#------------- CONTRIBUTION CORRPLOT ------------------------#

contrib <- var$contrib
colnames(contrib) = datalist
rownames(contrib) <- var_names
contrib_t <- t(contrib)

c2 <- ggcorrplot(contrib_t, method = "circle", tl.srt = 60, tl.cex = 25, tl.col = "black",  legend.title = "%")+
  scale_fill_gradient2(limit = c(min(contrib_t)-0.05, max(contrib_t)+0.05), low = "white", high = "red", 
                       mid = "orange", midpoint = (min(contrib_t) + max(contrib_t))/2)+
  labs(fill = "%") +
  theme(text = element_text(size = legend_text_size), legend.position="top",
        legend.key.size = unit(leg_size, "pt"),
        legend.key.width = unit(leg_width, "pt"),
        legend.text=element_text(size=legend_text_size, margin = margin(t = 0)))

ggsave(filename = "ggcorrplot_contrib.pdf", plot = c2, width = plot_width, height = plot_height, units = "mm")




    
