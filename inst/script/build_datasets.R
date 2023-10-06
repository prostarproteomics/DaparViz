# This script aims at regenerate the datasets embedded in the package 
# `DaparViz`.


library(DaparToolshedData)
library(QFeatures)
library(MSnbase)

finalSize <- 100

# Build data examples from DaparToolshedData (QFeatures)

data("Exp1_R25_pept", package='DaparToolshedData')
data("Exp1_R25_prot", package='DaparToolshedData')

ft1 <- Exp1_R25_pept[150:170]
ft2 <- Exp1_R25_prot[1:finalSize]

vData_ft1 <- convert2Viz(ft1)
vData_ft2 <- convert2Viz(ft2)
vData_ft <- vData_ft1
vData_ft[['processed_1']] <- vData_ft2[[1]]


save(vData_ft, file='data/vData_ft.RData')

# Build data examples from DAPARdata (MSnSet)

data("Exp1_R25_pept", package='DAPARdata')
data("Exp1_R25_prot", package='DAPARdata')

ms1 <- Exp1_R25_pept[150:170]
ms2 <- Exp1_R25_prot[1:finalSize]

vData_ms1 <- convert2Viz(ms1)
vData_ms2 <- convert2Viz(ms2)

vData_ms1 <- convert2Viz(ms1)
vData_ms2 <- convert2Viz(ms2)
vData_ms <- vData_ms1
vData_ms[['processed_1']] <- vData_ms2[[1]]

save(vData_ms, file='data/vData_ms.RData')