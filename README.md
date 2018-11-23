3C BenchTool is a set of shiny app designed to establish the efficiency of (over)clustering algorithms as well as optimizing their parameters by trying to maximize the F-score.
![Clustering and overclustering](https://github.com/isambens/3cclusteringtool/blob/master/doc/img1.png)
The F-score is defined as the harmonic mean of precision and recall but can also be expressed as a function of True and False Positives and Negatives. Depending on the type of method -- clustering or overclustering -- the computation of the F-score might be modified:
![Clustering - F score computation](https://github.com/isambens/3cclusteringtool/blob/master/doc/img2.png?raw=true "F-score computation with clustering algorithms")
Overclustering is trickier. We chose to group similar clusters into annotated groups.
![Overclustering - F score computation](https://github.com/isambens/3cclusteringtool/blob/master/doc/img3.png?raw=true "F-score computation with overclustering algorithms")

The 3 tools composing this toolkit are independant and can be used at different steps of the analysis. If you wish to create enriched files -- clustering your files and adding columns giving the cluster for each event -- use the "[3C Clustering Tool](http://github.com/isambens/3cclusteringtool))".
If your files were enriched/clustered using an algorithm not supported by 3C Clustering Tool, use "[3C Keywords Registor](http://github.com/isambens/3ckeywordsregistor))" to add the keywords enabling the analysis of the different algorithms used.
Finally, once your files are enriched and contain the necessary keywords, you can use "[3C Analysis Tool](http://github.com/isambens/3canalysistool))" visualize the different parameters causing the F-score to vary, thus exposing the issues which can be encountered while running certain algorithms.
![3C Analysis Pipeline](https://github.com/isambens/3cclusteringtool/blob/master/doc//img4.png "3C Analysis Pipeline")



# 3C - Clustering Tool
Shiny app developped to use different clustering algorithms on FCS files. The files are enriched and can then be downloaded and used with the Analysis Tool.
	 
>[User manual](https://github.com/isambens/3cclusteringtool/blob/master/doc/Manual_clusteringtool.pdf)

## Requirements
  * software: R(Version 3.4.3 to 3.5), Rstudio(optional)
  * R packages: flowcore, microbenchmark, ncdfFlow, shiny, shinydashboard, shinyjs, doSNOW, cluster, parallel, ggcyto, SPADECiphe
  
## Quick installation guide

  1. Run the following command in R/RStudio:
```
install.packages(c("microbenchmark", "shiny", "shinyjs", "shinydashboard","cluster","doSNOW","devtools"))
source("https://bioconductor.org/biocLite.R")
biocLite("ggcyto")
biocLite("flowCore")
biocLite("FlowSOM")
biocLite("ncdfFlow")
```
  >You might have to launch a new R session
  
  2. Run the next commands:
```
library("devtools")
install_github("nolanlab/rclusterpp")
install_github("isambens/spadeciphe")
install_github("isambens/ClusteringTool")
```

  
## Launching the shiny application

  1. Run the following commands in R/RStudio:
```
library("ClusteringTool")
ClusteringTool.run()
```  




# 3C Analysis Tool
Analysis tool used in a pipeline meant to establish the efficiency of clustering algorithms. Developped as a shiny app.

>[User manual ](https://github.com/isambens/3canalysistool/blob/master/doc/Manual_analysistool.pdf)
	
## Requirements
  * software: R(Version 3.4.3 to 3.5), Rstudio(optional)
  * R packages: flowcore, microbenchmark, ncdfFlow, shiny, shinydashboard, shinyjs, DT, RColorBrewer, ggplot2, easyGgplot2
  
## Quick installation guide

  1. Run the following command in R/RStudio:
```
install.packages("devtools")
library(devtools)
install_github("kassambara/easyGgplot2")
install.packages(c("microbenchmark","DT", "ggplot2", "RColorBrewer", "shiny", "shinyjs", "shinydashboard"))
source("https://bioconductor.org/biocLite.R")
biocLite("flowCore")
biocLite("ncdfFlow")
```
  >You may be asked to reload your environment, if so, accept.
  
  2. Run the next commands:
```
library("devtools")
install_github("isambens/AnalysisTool")
```

  
## Launching the shiny application

  1. Run the following commands in R/RStudio:
```
library("AnalysisTool")
AnalysisTool.run()
```  




# 3C Keywords Registor
Shiny app used to add keywords to an fcs enriched without Clustering Tool. Prior to Analysis Tool.

	
## Requirements
  * software: R(Version 3.4.3 to 3.5), Rstudio(optional)
  * R packages: flowcore, shiny, shinydashboard, shinyjs
  
## Quick installation guide

  1. Run the following command in R/RStudio:
```
install.packages(c("microbenchmark, "shiny", "shinyjs", "shinydashboard"))
source("https://bioconductor.org/biocLite.R")
biocLite("flowCore")
```
  >You may be asked to reload your environment, if so, accept.
  
  2. Run the next commands:
```
library("devtools")
install_github("isambens/KeywordsRegistor")
```

  
## Launching the shiny application

  1. Run the following commands in R/RStudio:
```
library("KeywordsRegistor)
KeywordsRegistor.run()
```  