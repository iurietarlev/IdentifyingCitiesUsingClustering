# This script includes all the helper functinos for the main script

# Author: Iurie Tarlev
# Date: 10/03/2019


#--------- FUNCTION FOR EXTRACTING SILHOUETTE COEFFICIENTS ---------------
# this function is designed to extract silhouette coefficients in df format
# for a given dataframe, with min_kn being the minimum amount of clusters
# and max_kn being the maximum amount of clusters
silhouettes <- function(raw_df, min_kn, max_kn) {
  
  df_pca  <- data.frame()
  clustm <- c("kmeans", "pam","agnes", "clara", "diana")
  x <- numeric()
  
  for (method in clustm) {
    for (clust_no in min_kn:max_kn) {
      clust.res <- eclust(raw_df, method, k=clust_no, graph = FALSE)
      clust.sil <- fviz_silhouette(clust.res, ggtheme = theme_minimal())
      sil_title <- clust.sil$labels$title
      sil_coeff <- as.numeric(unlist(regmatches(sil_title,gregexpr("[[:digit:]]+\\.*[[:digit:]]*",sil_title))))
      x <- cbind(method, clust_no, sil_coeff)
      df_pca <- rbind(df_pca,x)
      x <- numeric()
      #saveRDS(clust.res, file = sprintf("./Bath_PCA_rds_OUTPUTS/%s_%s_res_kn_%i.rds", region_analysed, i, j ))
    }
  }
  
  df_pca$method <- as.character(df_pca$method)
  df_pca$clust_no <-as.numeric(as.character(df_pca$clust_no))
  df_pca$sil_coeff <-as.double(as.character(df_pca$sil_coeff))
  return(df_pca)
}

#----------SELECTING VALUES IN THE DATAFRAME ACCORDING TO A PARTICULAR REGION-----
# with the loaded original data CSV file it is possible to load wither regions, county
# or country wide data, this function selects the correct data, given the name of the region
region_selector <- function(x){
  df_original <- read.csv("./stat_lsoa_england_urban_form_original_data.csv")
  regions <- c("East Midlands", "East of England", "Greater London", 
               "North East", "North West", "South East", "South West",
               "West Midlands", "Yorkshire and the Humber")
  
  if (x == 'England'){
    df_selection = df_original
    print('England')
    return(df_selection)
  } else if (is.element(x, regions) == TRUE){
    mask = df_original$REGION_NAME==x
    df_selection <- df_original[which(mask), ]
    return(df_selection)
    print('region')
  } else {
    mask = df_original$LA_NAME == x
    df_selection <- df_original[which(mask), ]
    return(df_selection)
    print('subregion')
  }
  
}
#-----SELECTING RDS files, which can then  be used for other purposes--------------------------------
save_df_to_rds <- function(df, nclust, dim_red_method, rds_dir){
  clustm <- c("kmeans", "pam", "agnes", "clara", "diana")
  for (method in clustm) {
    clust.res <- eclust(df, method, k=nclust, graph = FALSE)
    saveRDS(clust.res, file = sprintf("%s/%s_%s_%i_clust_df_%s.rds", rds_dir, dim_red_method, method, nclust,
                                      region_analysed))
  }
}

#==================================================================================================#
########-----------------> MODIFIED ORIGINAL SILHOUETTE PLOT FUNCTION <---------####################
#==================================================================================================#
# this function calculates the silhouettes and produces the plots, a few modifications have been applied
# to allow for more flexibility with the plotting format
fviz_silhouett <- function(sil.obj, label = FALSE, clust_method, print.summary = TRUE, ...){
  
  if(inherits(sil.obj, c("eclust", "hcut", "pam", "clara", "fanny"))){
    df <- as.data.frame(sil.obj$silinfo$widths)
  }
  else if(inherits(sil.obj, "silhouette"))
    df <- as.data.frame(sil.obj[, 1:3])
  else stop("Don't support an oject of class ", class(sil.obj))
  
  # order by cluster and by sil_width
  df <- df[order(df$cluster, -df$sil_width), ]
  if(!is.null(rownames(df))) df$name <- factor(rownames(df), levels = rownames(df))
  else df$name <- as.factor(1:nrow(df))
  df$cluster <- as.factor(df$cluster)
  mapping <- aes_string(x = "name", y = "sil_width", 
                        color = "cluster", fill = "cluster")
  
  #ggplot colour scheme definition
  gg_color_hue <- function(n) {
    hues = seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
  }
  
  p <- ggplot(df, mapping) +
    geom_bar(stat = "identity", width = 0.2) +
    scale_colour_manual(values=gg_color_hue(6)) + 
    labs(y = "Silhouette width", x = "",
         title = paste0(clust_method, " Silhouette Plot",
                        "\n Average silhouette width: ", 
                        round(mean(df$sil_width), 2)))+
    ggplot2::ylim(c(NA, 1))+
    geom_hline(yintercept = mean(df$sil_width), linetype = "dashed", color = "red", width = 0.05)
  p <- ggpubr::ggpar(p, palette = gg_color_hue(6), ...)
  # Labels
  if(!label) p <- p + theme(axis.text.x = element_blank(), 
                            axis.ticks.x = element_blank())
  else if(label)
    p <- p + theme(axis.text.x = element_text(angle=45))
  
  # Print summary
  ave <- tapply(df$sil_width, df$cluster, mean)
  n <- tapply(df$cluster, df$cluster, length)
  sil.sum <- data.frame(cluster = names(ave), size = n,
                        ave.sil.width = round(ave,2))
  if(print.summary) print(sil.sum)
  
  p
}


#----------- MAKE MULTIPLE CLUSTERING AND SILHOUETTE PLOTS ON ONE PAGE--------------
# this function allows for various configurations of the formatting when plotting
# multiple cluster plots and silhouette plots on one page
clust_sil_plots <- function(df, nclust, dim_red_method, save_dir, geom_type, 
                            axis_text_size, legend_text_size, title_size, label_size, 
                            point_size, leg_size, leg_width,
                            plot_width, plot_height){
  clustm <- c("kmeans", "pam", "agnes", "clara", "diana")
  theme_viz = theme(legend.position="right", legend.title = element_text(size = axis_text_size),
                    #legend.spacing.y = unit(0.3, 'cm'),
                    axis.title = element_text(size=axis_text_size),
                    axis.text = element_text(size = axis_text_size),
                    legend.text=element_text(size=legend_text_size, margin = margin(t = 0)),
                    plot.title = element_text(hjust = 0.5, size=title_size, face="bold"),
                    axis.line=element_blank(),
                    legend.key.size = unit(leg_size, "pt"),
                    legend.key.width = unit(leg_width, "pt"),
                    panel.grid = element_line(size = 0.25),
                    line = element_line(size = 0.05))
  
  theme_sil = theme(legend.position="right", legend.title = element_text(size = axis_text_size),
                    #legend.spacing.y = unit(0.3, 'cm'),
                    axis.title = element_text(size=axis_text_size),
                    axis.text = element_text(size = axis_text_size),
                    legend.text=element_text(size=legend_text_size, margin = margin(t = 0)),
                    plot.title = element_text(hjust = 0.5, size=title_size, face="bold"),
                    axis.line=element_blank(),
                    legend.key.size = unit(leg_size, "pt"),
                    legend.key.width = unit(leg_width, "pt"),
                    panel.grid.major.x = element_line(size = 0.1),
                    panel.grid.major.y = element_line(size = 0.25))
  
  clustm_labels <- c("K-means", "PAM", "AGNES", "CLARA", "DIANA")
  
  myplots <- list()
  i <- 1
  clustm_i <- 1
  #nclust = 6
  for (method in clustm) {
    clust.res <- eclust(df, method, k=nclust, graph = FALSE)
    clust.sil <- fviz_silhouett(clust.res, ggtheme = theme_sil, clust_method = clustm_labels[clustm_i]) + 
      scale_y_continuous(limits = c(NA, 1), expand = c(0,0), breaks = seq(0,1,0.5))
    #scale_size_discrete(range = c(1,2))
    #
    
    
    clust.viz <- fviz_cluster(clust.res, repel = TRUE, show.clust.cent = TRUE,
                              main = sprintf("%s Cluster Plot", clustm_labels[clustm_i]), 
                              ggtheme = theme_viz, labelsize = label_size, geom = c(geom_type), 
                              pointsize = point_size,
                              xlab = FALSE, ylab = FALSE)
    
    myplots[[i]] <- clust.viz
    myplots[[i+1]] <- clust.sil
    i <- i + 2
    clustm_i <- clustm_i +1
  }
  
  
  library(grid)
  m_plots <- grid.arrange(grobs = myplots, ncol=2, nrow=(length(myplots)/2)) #, top = textGrob(paste(dim_red_method,region_analysed, "-", nclust, "clusters"), gp=gpar(fontsize=20,font=8)))
  ggsave(filename = sprintf("%s/%s_Clustering_%i_clust_%s_%s.pdf",save_dir, dim_red_method, nclust, region_analysed, geom_type), 
         plot = m_plots, width = plot_width, height = plot_height, units = "mm")
}


#----------- PCA DATAFRAME TRANFORMATION --------------------------------------
# this functions transforms the original dataframe into a PCA compoents one
# full_name option is left, when a full name of the region needs to be retained, 
# rather than truncated to the LSAO LA_NAME codes

pca_transform <- function(dataframe, regionality, n_comp, full_name){
  names <- dataframe$LSOA_NAME
  df <- data.frame(dataframe[,5:36])
  
  myPr <- prcomp(df, scale = TRUE)
  std_dev <- myPr$sdev
  
  #compute variance
  pr_var <- std_dev^2
  prop_varex <- pr_var/sum(pr_var)
  
  
  #E XTRACT DATA FROM OBSERVATIONS
  measures = myPr$x
  measures = data.frame(measures) 
  
  # TRUNCATE MEASURES TO N COMPONENTS
  sigfact = measures[,1:n_comp]
  
  #name the rows
  rownames(sigfact) <- names
  
  # use significant factors to do clustering on
  X=data.frame(sigfact)
  #label rows with last four coefficients 
  
  
  
  regions <- c("East Midlands", "East of England", "Greater London", 
               "North East", "North West", "South East", "South West",
               "West Midlands", "Yorkshire and the Humber", "England")
  
  if (is.element(regionality, regions) == TRUE || full_name == TRUE ){
    return(X)
    #print("TRUE")
  } else {
    #print("FALSE")
    names_vector = as.matrix(names)
    names_v <- substr(names_vector,nchar(names_vector)-4,nchar(names_vector))
    rownames(X) <- names_v
    return(X)
  }
  
}

#-------------TSNE DATAFRAME TRANSFORMATION------------------------------------------------
# transforms original data into a tSNE coordinates dataframe
# very resource intensive, therefore should be run on small regions only on personal computers
tsne_transform <- function(dataframe, regionality, perplexity, max_iter, seed, full_name){
  
  names <- dataframe$LSOA_NAME
  df <- data.frame(dataframe[,5:36])
  
  set.seed(seed)
  tsne_out <- Rtsne(as.matrix(df),perplexity=perplexity,verbose=TRUE,max_iter = max_iter)
  tsne_df <- data.frame(tsne_out$Y,row.names = names)
  colnames(tsne_df) = c("X", "Y")
  
  regions <- c("East Midlands", "East of England", "Greater London", 
               "North East", "North West", "South East", "South West",
               "West Midlands", "Yorkshire and the Humber", "England")
  
  if (is.element(regionality, regions) == TRUE || full_name == TRUE ){
    return(tsne_df)
    #print("TRUE")
  } else {
    #print("FALSE")
    names_vector = as.matrix(names)
    names_v <- substr(names_vector,nchar(names_vector)-4,nchar(names_vector))
    rownames(tsne_df) <- names_v
    return(tsne_df)
  }
}


#----------------PLOT COMPARISON OF SILHOUETTES FOR PCA AND TSNE---------------------#
# this function plots silhouette coefficients versus number of clusters for multiple clusters in a row
plot_silhouettes <- function(pca, tsne, palette_colour, legend_text_size,
                             axis_text_size, title_size, aspect_ratio, 
                             x_label, y_label, point_size, widthx, heightx){
  ggthemr("pale")
  p1 <- ggplot(pca, aes(x = clust_no, y = sil_coeff, group = method, color = method, palette = 'jco')) +
    geom_line() + ylab(label = y_label) + xlab(label = x_label) + 
    geom_point(size = point_size) + 
    scale_x_continuous(breaks = seq(0, 100, 2)) +
    scale_y_continuous(breaks = seq(0, 1, 0.04)) +
    scale_color_manual(values=brewer.pal(n=5, name=palette_colour)) +
    labs(col = "") +
    ggtitle("PCA Validation") + theme(legend.position="none", axis.title.y = element_text(size=axis_text_size),
                                      axis.title.x = element_text(size=axis_text_size),
                                      legend.text=element_text(size=legend_text_size),
                                      #axis.text.x = element_text(angle = 45, size = (axis_text_size -3)), 
                                      aspect.ratio=aspect_ratio, plot.title = element_text(hjust = 0.5, size=title_size, face="bold"))
  
  
  p2 <- ggplot(tsne, aes(x = clust_no, y = sil_coeff, group = method, color = method, palette = 'jco')) +
    geom_line() + ylab(label = y_label) + xlab(label = x_label) + 
    geom_point(size = point_size) +
    scale_x_continuous(breaks = seq(0, 100, 2)) +
    scale_y_continuous(breaks = seq(0, 1, 0.04)) +
    scale_color_manual(values=brewer.pal(n=5, name=palette_colour)) +
    labs(col = "") +
    ggtitle("t-SNE Validation") + theme(legend.position="none", axis.title.y = element_text(size=axis_text_size),
                                        axis.title.x = element_text(size=axis_text_size),
                                        legend.text=element_text(size=legend_text_size),
                                        #axis.text.x = element_text(angle = 45, size = (axis_text_size -3)),
                                        aspect.ratio=aspect_ratio, plot.title = element_text(hjust = 0.5, size=title_size, face="bold"))
  
  m_plots <- ggarrange(p1, p2, ncol=2, nrow=1, common.legend = TRUE, align = "hv", legend = "top")
  ggsave(filename = sprintf("%s/Validation_Plots_%s.pdf", direction, region_analysed), 
         plot = m_plots, width = widthx, height = heightx, units = 'mm')
  
  
  
}

  
# ----- CONVERT RDS FILES INTO CSVs FOR MAP PLOTTING USING PYTHON (PARTITIONAL CLUSTERING) ----- #
  
save_csv_for_plotting_partitional <- function(dim_red_method, nclust, rds_dir, csv_dir){
  clustm <- c("kmeans", "pam", "clara")
  for (method in clustm) {
    clust.res <- readRDS(file = sprintf("%s/%s_%s_%i_clust_df_%s.rds", rds_dir, dim_red_method, 
                                        method, nclust, region_analysed))
    
    #____create a dataframe with assigned cluster numbers
    clustering_df = data.frame(clust.res$cluster)
    clustering_df <- data.frame(rownames(clustering_df),clustering_df)
    colnames(clustering_df) = c("LSOA_NAME", "CLUSTER")
    
    #____merge the df with cluster numbers with the df which holds the LSOA codes
    clustering_df = merge(clustering_df[, c("LSOA_NAME","CLUSTER")], df_selection[, c("LSOA_NAME","LSOA_CODE")])
    
    colnames(clustering_df) = c("LSOA_NAME", "CLUSTER", "CODE")
    write.csv(clustering_df, file = sprintf("%s/%s_%s_%i_clust_df_%s.csv", csv_dir, dim_red_method, 
                                            method, nclust, region_analysed))
  }
}
 
# ----- CONVERT RDS FILES INTO CSVs FOR MAP PLOTTING USING PYTHON  (HIERARCHICAL CLUSTERING) ----- #

save_csv_for_plotting_hierarchical <- function(dim_red_method, nclust, rds_dir, csv_dir){
  clustm <- c("diana", "agnes")
  for (method in clustm) {
    #____create a dataframe with assigned cluster numbers
    clust.res <- readRDS(file = sprintf("%s/%s_%s_%i_clust_df_%s.rds", rds_dir, dim_red_method, 
                                        method, nclust, region_analysed))
    kmeans_res <- readRDS(file = sprintf("%s/%s_%s_%i_clust_df_%s.rds", rds_dir, dim_red_method, 
                                         "kmeans", nclust, region_analysed))
    clustering_df = data.frame(rownames(as.matrix(kmeans_res$cluster)),clust.res$cluster)
    colnames(clustering_df) = c("LSOA_NAME", "CLUSTER")
    
    #____merge the df with cluster numbers with the df which holds the LSOA codes
    clustering_df = merge(clustering_df[, c("LSOA_NAME","CLUSTER")], df_selection[, c("LSOA_NAME","LSOA_CODE")])
    
    colnames(clustering_df) = c("LSOA_NAME", "CLUSTER", "CODE")
    write.csv(clustering_df, file = sprintf("%s/%s_%s_%i_clust_df_%s.csv", csv_dir, dim_red_method, 
                                            method, nclust, region_analysed))
  }
}   
