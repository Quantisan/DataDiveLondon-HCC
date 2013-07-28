library(randomForest)

index <- sample(x=c(TRUE,FALSE), replace=TRUE, size=nrow(predictors2), prob=c(.75,.25))


# initial logistic regression to asses predictive power of mosaic
fit.logref <- glm(formula=AlternativeNeedCode~MOSAIC, data=set.lsoa, family=binomial(link="logit"))
summary(fit.logref)


# all variables but lsoa and sen 
train1 <- predictors2[index,-c(2,25)]
test1 <- predictors2[!index,-c(2,25)]

fit.lm1 <- lm(prop.sen~., data=train1)
summary(fit.lm1)
pred1 <- predict(fit.lm1, newdata=test1)
mse1 <- sum((pred1 - test1$prop.sen)^2)/length(pred1)

# most significant variables only
train2 <- predictors2[index, c(1,3,8,9,24,27)]
test2 <- predictors2[!index, c(1,3,8,9,24,27)]


fit.lm2 <- lm(prop.sen~., data=train2)
summary(fit.lm2)
pred2 <- predict(fit.lm2, newdata=test2)
mse2 <- sum((pred2 - test2$prop.sen)^2)/length(pred2)

# randomForest test
train3 <- predictors2[index,-c(2,25)]
test3 <- predictors2[!index,-c(2,25)]

x3 <- train3[,-24]
y3 <- train3[,24]
x3.test <- test3[,-24]
y3.test <- test3[,24]

fit.rf1 <- randomForest(x=x3, y=y3)
pred3 <- predict(fit.rf1, x3.test)

mse3 <- sum((pred3 - y3.test)^2)/length(pred3)

# bring back lsoa to the model
train4 <- predictors2[index,-c(25)]
test4 <- predictors2[!index,-c(25)]

test4 <- test4[!(test4$LSOA.CODE %in% c("E01017054", "E01017151", "E01017154", "E01017164", "E01017169", "E01017172", "E01017188", "E01017205", "E01017208", "E01017227", "E01017238", "E01017247", "E01017268", "E01022479", "E01022525", "E01022655", "E01022667", "E01022696", "E01022700", "E01022714", "E01022741", "E01022795", "E01022821", "E01022838", "E01022855", "E01022876", "E01022962", "E01023006", "E01023052", "E01023130", "E01023240")),]

fit.lm4 <- lm(prop.sen~., data=train4)

pred4 <- predict(fit.lm4, newdata=test4)
mse4 <- sum((pred4 - test4$prop.sen)^2)/length(pred4)
