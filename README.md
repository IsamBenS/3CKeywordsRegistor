# Keywords Registor
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