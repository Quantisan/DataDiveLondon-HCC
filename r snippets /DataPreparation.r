library(reshape2)
library(data.table)

prediction.data.raw <- read.table(file="../hampshire_depr_data.csv", header=TRUE, sep=",")


prediction.data.melt <- melt(prediction.data.raw[,c("YEAR","LSOA.CODE","IMD.SCORE","Aged.0","Aged.1","Aged.2","Aged.3","Aged.4","Aged.5","Aged.6","Aged.7","Aged.8","Aged.9","Aged.10","Aged.11","Aged.12","Aged.13","Aged.14","Aged.15","Aged.16","Aged.17","Aged.18","Aged.19")], id.vars=c("YEAR", "LSOA.CODE", "IMD.SCORE"), measures.var=c("Aged.0","Aged.1","Aged.2","Aged.3","Aged.4","Aged.5","Aged.6","Aged.7","Aged.8","Aged.9","Aged.10","Aged.11","Aged.12","Aged.13","Aged.14","Aged.15","Aged.16","Aged.17","Aged.18","Aged.19"))

prediction.data <- dcast(prediction.data.melt, formula="YEAR+LSOA.CODE+IMD.SCORE+variable~.")

names(prediction.data) <- c("year","lsoa","imd.score","age","population")

prediction.data$age <- as.numeric(gsub("Aged.", "", prediction.data$age))

set.lsoa$age <- set.lsoa$YearOfSENID-set.lsoa$Year.ofBirth

sen <- set.lsoa[,
                list(sen1=sum(AlternativeNeedCode=="1"),
                     sen2=sum(AlternativeNeedCode=="2"),
                     sen3=sum(AlternativeNeedCode=="3"),
                     sen4=sum(AlternativeNeedCode=="4"),
                     sen5=sum(AlternativeNeedCode=="5"),
                     sen6=sum(AlternativeNeedCode=="6"),
                     sen7=sum(AlternativeNeedCode=="7"),
                     sen8=sum(AlternativeNeedCode=="8"),
                     sen9=sum(AlternativeNeedCode=="9"),
                     sen10=sum(AlternativeNeedCode=="10"),
                     sen11=sum(AlternativeNeedCode=="11"),
                     sen12=sum(AlternativeNeedCode=="12"),
                     sen13=sum(AlternativeNeedCode=="13"),
                     sen14=sum(AlternativeNeedCode=="14"),
                     sen15=sum(AlternativeNeedCode=="15"),
                     sen16=sum(AlternativeNeedCode=="16")
                     ),
                by=c("YearOfSENID", "LLSOA", "age")
                ]

sen2 <- set.lsoa[,
                list(SEN=sum(!is.na(AlternativeNeedCode)),
                     AVG_AGE=mean(age)
                     ),
                by=c("YearOfSENID", "LLSOA")
                ]

predictors <- merge(prediction.data, sen, by.x=c("year","lsoa","age"), by.y=c("YearOfSENID","LLSOA","age"))


prediction.data2 <- prediction.data.raw[,c(1,2,7,12:31,46)]
predictors2 <- merge(prediction.data2, sen2, by.x=c("YEAR","LSOA.CODE"), by.y=c("YearOfSENID","LLSOA"))


predictors2$prop.sen <- predictors2$SEN/predictors2$Total





