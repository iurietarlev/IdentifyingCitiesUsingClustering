# This program is designed to plot the % of variance explained
# by each principal component (for first 6 components only)

# Author: Iurie Tarlev
# Date: 23/03/2019

# ------ LOAD REQUIRED LIBRARIES ------ #
library(ggplot2)      #used for ggplot
library(factoextra)   #used for eclust function
library(RColorBrewer) #used for color palettes for ggplot
library(ggthemr)      #theme for plotting in ggplot

# ------ SET CURRENT WORKING DIRECTORY (RStudio) ------ #
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

#--------------- REGION SELECTOR FUNCTION ---------------------#
# selects the data for the right region depending on the input
region_selector <- function(x){
  df_original <- read.csv("../stat_lsoa_england_urban_form_original_data.csv")
  regions <- c("East Midlands", "East of England", "Greater London", 
               "North East", "North West", "South East", "South West",
               "West Midlands", "Yorkshire and the Humber")
  
  if (x == 'England'){
    df_selection = df_original
    #print('England')
    return(df_selection)
  } else if (is.element(x, regions) == TRUE){
    mask = df_original$REGION_NAME==x
    df_selection <- df_original[which(mask), ]
    return(df_selection)
    #print('region')
  } else {
    mask = df_original$LA_NAME == x
    df_selection <- df_original[which(mask), ]
    return(df_selection)
    #print('subregion')
  }
  
}


#---------- READ DATA FOR PARITUCLAR REGION OF INTEREST --------------#
region_analysed = "Bath and North East Somerset"
df_selection <- region_selector(region_analysed)
df_selection


# set a variable called names to the LSOA names of the area selected
names <- df_selection$LSOA_NAME

# extract only parameter/number columns for PCA
df <- data.frame(df_selection[,5:36])
myPr <- prcomp(df, scale = TRUE)
std_dev <- myPr$sdev

# compute variance
pr_var <- std_dev^2
prop_varex <- pr_var/sum(pr_var)


# ------ SET PLOTTING PARAMETERS ------ #
theme.size = 24 #the size of the labels on the graph
geom.text.size = (5/14)*theme.size
axis.title.size = 25
axis.label.size = 25
point_size = 3.5

#------------------------------------ SCREE PLOT---------------------------------------------- #
prop_var<- (round(prop_varex*100, digits = 1)) #add up proportion of variance and round it
prop_var <- data.frame(prop_var)               #convert data to a dataframe
dim_no <- rownames(prop_var)                   #get the row names for dataframe
proportion_var <- cbind(dim_no, prop_var)      #comine dimensions and cummulative variance in one df

y_label = "% of Variance Explained"
x_label = "Dimension"

# converting the dim_no to the factor format, for bar plotting in ggplot
proportion_var$dim_no <- factor(proportion_var$dim_no, levels = proportion_var$dim_no)
proportion_var <- proportion_var[1:10,] #selecting only the first 10 dimensions to be plotted

# ggplotting the data
scree <- ggplot(proportion_var, aes(x = dim_no, y=prop_var, group = 1, label = prop_var)) + ylab(label = y_label) + xlab(label = x_label) +
  geom_col(fill = "steelblue")+ #ggtitle("Scree Plot") +
  geom_line(color = "gray12") + ylim(0, 35) +
  geom_point(color = "gray12", size = point_size)+
  theme_minimal()+
  theme(axis.ticks.x = element_line(colour = "black"), axis.ticks.y = element_line(colour = "black"),
        axis.text.x = element_text(size = axis.label.size),
        axis.text.y=element_text(vjust=0, size = axis.label.size),
        axis.title = element_text(size = axis.title.size),
        text = element_text(size = theme.size))


#-----------------------------CUMMULATIVE SCREE PLOT---------------------------------------------- #
cum_var<- cumsum((round(prop_varex*100, digits = 1))) #add up proportion of variance and round it
cum_var <- data.frame(cum_var)                        #convert data to a dataframe
dim_no <- rownames(cum_var)                           #get the row names for dataframe
cummulative_var <- cbind(dim_no, cum_var)             #comine dimensions and cummulative variance in one df

y_label = "Cum. % of Variance Explained "
x_label = "Dimension"

# converting the dim_no the factor format, for bar plotting in ggplot
cummulative_var$dim_no <- factor(cummulative_var$dim_no, levels = cummulative_var$dim_no)
cummulative_var <- cummulative_var[1:10,] #selecting only the first 10 dimensions to be plotted

# ggplotting the data
cum_scree <- ggplot(cummulative_var, aes(x = dim_no, y=cum_var, group = 1, label = cum_var)) + 
  ylab(label = y_label) + xlab(label = x_label) +
  geom_col(fill = "steelblue") + #ggtitle("Cummulative Scree Plot") +
  geom_line(color = "gray12") + ylim(0, 100) +
  geom_point(color = "gray12", size = point_size)+
  theme_minimal()+ geom_segment(aes(x = 6, y = 0, xend = 6, yend = 75.5), linetype="dashed") +
  annotate(geom="text", x=5.95, y=83, label="75.5%",color="black", size = geom.text.size) +
  theme(axis.ticks.x = element_line(colour = "black"), axis.ticks.y = element_line(colour = "black"),
        axis.text = element_text(size = axis.label.size), axis.title = element_text(size = axis.title.size),
        text = element_text(size = theme.size))

ggsave(filename = "ScreePlot_Bath.pdf", scree, width = 7.5, height = 7.5)
ggsave(filename = "CumScreePlot_Bath.pdf", cum_scree, width = 7.5, height = 7.5)



