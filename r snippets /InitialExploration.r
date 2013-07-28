library(data.table)

# load original file
 set.lsoa <- read.table(file="../OriginalData/qryAnonymisedDataSET_LSOA.txt", sep=",", header=TRUE)

# adjust data types
set.lsoa <- transform(set.lsoa,
                      PUPIL_ID=as.factor(PUPIL_ID),
                      AlternativeDesc=as.factor(AlternativeDesc),
                      AlternativeNeedCode=as.factor(AlternativeNeedCode))

# replace NULL by NA
set.lsoa$AlternativeNeedCode <- as.factor(ifelse(set.lsoa$AlternativeNeedCode=="NULL",NA,set.lsoa$AlternativeNeedCode))

# high level view of the data
str(set.lsoa)
summary(set.lsoa)
nrow(set.lsoa) # 202,418

write.table(summary(set.lsoa), file=pipe("pbcopy"), sep="\t")

# pupil_id distribution
count.pupil.id <- table(set.lsoa$PUPIL_ID)
hist(count.pupil.id)

# year of birth
hist(set.lsoa$Year.ofBirth)

# year of SENID
hist(set.lsoa$YearOfSENID)

# sp matrix
pairs(set.lsoa)

set.lsoa <- data.table(set.lsoa)
 
by.pupil <- set.lsoa[,
                     list(count.rows=length(1)
                          count.YearofBirth=length),
                     by=PUPIL_ID]

plot(table(set.lsoa$MOSAIC, set.lsoa$AlternativeNeedCode))

plot(as.numeric(set.lsoa$MOSAIC), as.numeric(set.lsoa$AlternativeNeedCode))
