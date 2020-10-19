library(adjutant)
library(dplyr)
library(ggplot2)
library(tidytext) #for stop words
require(Rtsne)

#also set a seed - there is some randomness in the analysis.
set.seed(416)

df<-processSearch("(microbiome OR virome) AND torque AND teno AND virus",retmax=10000)
tidy_df<-tidyCorpus(corpus = df)
# X <- tidy_df[, c("tf", "idf", "tf_idf")]
tsneObj<-runTSNE(tidy_df, check_duplicates=FALSE, perplexity = 20)
# tsne <- Rtsne(X = tidy_df, check_duplicates = F, pca = F, verbose = T)
# tsneObj <- data.frame(tsne$Y)
# tsneObj$PMID <- tidy_df$PMID

#add t-SNE co-ordinates to df object
plot_df<-inner_join(tidy_df, tsneObj, by="PMID")

# df<-inner_join(df,tsneObj$Y,by="PMID")
runTSNE <- function (tidyCorpus_df) {
  dtm <- cast_dtm(tidy_df, PMID, wordStemmed, tf_idf)
  tsneObj <- Rtsne(as.matrix(dtm), perplexity = 5, check_duplicates = F)
  tsneObj$Y <- data.frame(cbind(rownames(dtm), tsneObj$Y), 
                          stringsAsFactors = F)
  colnames(tsneObj$Y) <- c("PMID", paste("tsneComp", 
                                         1:(ncol(tsneObj$Y) - 1), sep = ""))
  tsneObj$Y[, 2:ncol(tsneObj$Y)] <- sapply(tsneObj$Y[, 2:ncol(tsneObj$Y)], 
                                           as.numeric) %>% unname()
  return(tsneObj)
}

tsneObj<- runTSNE(tidy_df)
# HDBSCan
optClusters <- optimalParam(data.frame(X1=plot_df$X1, X2=plot_df$X2))
# plot the t-SNE results
ggplot(df,aes(x=X1,y=X2))+
  geom_point(alpha=0.2)+
  theme_bw()

#run HDBSCAN and select the optimal cluster parameters automaticallu
optClusters <- optimalParam(df)

#add the new cluster ID's the running dataset
df<-inner_join(df,optClusters$retItems,by="PMID") %>%
  mutate(tsneClusterStatus = ifelse(tsneCluster == 0, "not-clustered","clustered"))

# plot the HDBSCAN clusters (no names yet)
clusterNames <- df %>%
  dplyr::group_by(tsneCluster) %>%
  dplyr::summarise(medX = median(tsneComp1),
                   medY = median(tsneComp2)) %>%
  dplyr::filter(tsneCluster != 0)

ggplot(df,aes(x=tsneComp1,y=tsneComp2,group=tsneCluster))+
  geom_point(aes(colour = tsneClusterStatus),alpha=0.2)+
  geom_label(data=clusterNames,aes(x=medX,y=medY,label=tsneCluster),size=2,colour="red")+
  stat_ellipse(aes(alpha=tsneClusterStatus))+
  scale_colour_manual(values=c("black","blue"),name="cluster status")+
  scale_alpha_manual(values=c(1,0),name="cluster status")+ #remove the cluster for noise
  theme_bw()

clustNames<-df %>%
  group_by(tsneCluster)%>%
  mutate(tsneClusterNames = getTopTerms(clustPMID = PMID,clustValue=tsneCluster,topNVal = 2,tidyCorpus=tidy_df)) %>%
  select(PMID,tsneClusterNames) %>%
  ungroup()

#update document corpus with cluster names
df<-inner_join(df,clustNames,by=c("PMID","tsneCluster"))

#re-plot the clusters

clusterNames <- df %>%
  dplyr::group_by(tsneClusterNames) %>%
  dplyr::summarise(medX = median(tsneComp1),
                   medY = median(tsneComp2)) %>%
  dplyr::filter(tsneClusterNames != "Not-Clustered")

ggplot(df,aes(x=tsneComp1,y=tsneComp2,group=tsneClusterNames))+
  geom_point(aes(colour = tsneClusterStatus),alpha=0.2)+
  stat_ellipse(aes(alpha=tsneClusterStatus))+
  geom_label(data=clusterNames,aes(x=medX,y=medY,label=tsneClusterNames),size=3,colour="red")+
  scale_colour_manual(values=c("black","blue"),name="cluster status")+
  scale_alpha_manual(values=c(1,0),name="cluster status")+ #remove the cluster for noise
  theme_bw()