library('tm')
library('class')

setwd("/home/jawa/Downloads/d/erik-08-11.2/")

docs <- c('redditcyberpunk','redditbrasilknn','reddittrains','redditsad','redditthepiratebay')
num.train <- list(cyberpunk = 4812, brasil = 14510, trains = 803, sad = 190, thepiratebay = 471)
num.test <- list(cyberpunk = 2406, brasil = 7254, trains = 401, sad = 94, thepiratebay = 235)

rd.cyberpunk <- read.csv('redditcyberpunk.csv', stringsAsFactors = FALSE, header = FALSE)
rd.cyberpunk.train <- head(rd.cyberpunk, n = ceiling(nrow(rd.cyberpunk) * 2/3))
rd.cyberpunk.test <- tail(rd.cyberpunk, n = floor(nrow(rd.cyberpunk) * 1/3))
num.train['cyberpunk'] = ceiling(nrow(rd.cyberpunk) * 2/3)
num.test['cyberpunk'] = floor(nrow(rd.cyberpunk) * 1/3)

rd.brasil <- read.csv('redditbrasilknn.csv', stringsAsFactors = FALSE, header = FALSE)
rd.brasil.train <- head(rd.brasil, n = ceiling(nrow(rd.brasil) * 2/3))
rd.brasil.test <- tail(rd.brasil, n = floor(nrow(rd.brasil) * 1/3))
num.train['brasil'] = ceiling(nrow(rd.brasil) * 2/3)
num.test['brasil'] = floor(nrow(rd.brasil) * 1/3)

rd.trains <- read.csv('reddittrains.csv', stringsAsFactors = FALSE, header = FALSE)
rd.trains.train <- head(rd.trains, n = ceiling(nrow(rd.trains) * 2/3))
rd.trains.test <- tail(rd.trains, n = floor(nrow(rd.trains) * 1/3))
num.train['trains'] = ceiling(nrow(rd.trains) * 2/3)
num.test['trains'] = floor(nrow(rd.trains) * 1/3)

rd.sad <- read.csv('redditsad.csv', stringsAsFactors = FALSE, header = FALSE)
rd.sad.train <- head(rd.sad, n = ceiling(nrow(rd.sad) * 2/3))
rd.sad.test <- tail(rd.sad, n = floor(nrow(rd.sad) * 1/3))
num.train['sad'] = ceiling(nrow(rd.sad) * 2/3)
num.test['sad'] = floor(nrow(rd.sad) * 1/3)

rd.thepiratebay <- read.csv('redditthepiratebay.csv', stringsAsFactors = FALSE, header = FALSE)
rd.thepiratebay.train <- head(rd.thepiratebay, n = ceiling(nrow(rd.thepiratebay) * 2/3))
rd.thepiratebay.test <- tail(rd.thepiratebay, n = floor(nrow(rd.thepiratebay) * 1/3))
num.train['thepiratebay'] = ceiling(nrow(rd.thepiratebay) * 2/3)
num.test['thepiratebay'] = floor(nrow(rd.thepiratebay) * 1/3)

rm(rd.cyberpunk)
rm(rd.brasil)
rm(rd.trains)
rm(rd.sad)
rm(rd.thepiratebay)

#each vector line into a document
tm <- c(Corpus(VectorSource(rd.cyberpunk.train$V1)),
        Corpus(VectorSource(rd.brasil.train$V1)),
        Corpus(VectorSource(rd.trains.train$V1)),
        Corpus(VectorSource(rd.sad.train$V1)),
        Corpus(VectorSource(rd.thepiratebay.train$V1)),
        Corpus(VectorSource(rd.cyberpunk.test$V1)),
        Corpus(VectorSource(rd.brasil.test$V1)),
        Corpus(VectorSource(rd.trains.test$V1)),
        Corpus(VectorSource(rd.sad.test$V1)),
        Corpus(VectorSource(rd.thepiratebay.test$V1)))

#cleaning
tm <- tm_map(tm, content_transformer(tolower))
tm <- tm_map(tm, removePunctuation)
tm <- tm_map(tm, stripWhitespace)
tm <- tm_map(tm, removeNumbers)
dat <- readLines("/home/jawa/Downloads/d/erik-08-11.2/stop.txt")
tm<- tm_map(tm, removeWords, dat)
tm<- tm_map(tm, removeWords, c("deleted"))
rm(dat)

#dtm
dtm <-DocumentTermMatrix(tm, control=list(weighing=weightTfIdf, minWordLength=2, minDocFreq=5))

#dtm into a dataframe and reducing sparsity
df <- as.data.frame( inspect(removeSparseTerms(dtm, 0.99)) )

#apending class info
class <- c(rep('cyberpunk', as.numeric(num.train['cyberpunk'])),
           rep('brasil', as.numeric(num.train['brasil'])),
           rep('trains', as.numeric(num.train['trains'])),
           rep('sad', as.numeric(num.train['sad'])),
           rep('thepiratebay', as.numeric(num.train['thepiratebay'])),
           rep('cyberpunk', as.numeric(num.test['cyberpunk'])),
           rep('brasil', as.numeric(num.test['brasil'])),
           rep('trains', as.numeric(num.test['trains'])),
           rep('sad', as.numeric(num.test['sad'])),
           rep('thepiratebay', as.numeric(num.test['thepiratebay']))
           )
class.tr <- c(rep('cyberpunk', as.numeric(num.train['cyberpunk'])),
              rep('brasil', as.numeric(num.train['brasil'])),
              rep('trains', as.numeric(num.train['trains'])),
              rep('sad', as.numeric(num.train['sad'])),
              rep('thepiratebay', as.numeric(num.train['thepiratebay']))
           )
class.ts <- c(rep('cyberpunk', as.numeric(num.test['cyberpunk'])),
              rep('brasil', as.numeric(num.test['brasil'])),
              rep('trains', as.numeric(num.test['trains'])),
              rep('sad', as.numeric(num.test['sad'])),
              rep('thepiratebay', as.numeric(num.test['thepiratebay']))
           )
df <- cbind(df, class)

#==**KNN**=====================================================
#generating training data for KNN clasifier
#test and training vectors must have the same size for k-nn

last.col <- ncol(df) - 1

require(imputation)

#for loop, without the for
it1 <- 1
it2 <- as.numeric(num.test["cyberpunk"])
it3 <- 1
it4 <- 0
knn.dtm.tr <- df[it1:it2, 1:last.col]
knn.class.tr <- df[it1:it2, last.col + 1]

it1 <- it1 + as.numeric(num.test["cyberpunk"])
it2 <- it2 + as.numeric(num.test["brasil"])
it3 <- it3 + as.numeric(num.train["cyberpunk"])
it4 <- it4 + as.numeric(num.train["cyberpunk"]) + as.numeric(num.test["brasil"])
knn.dtm.tr[it1:it2,] <- df[it3:it4, 1:last.col]
knn.class.tr[it1:it2] <- df[it3:it4, last.col + 1]

it1 <- it1 + as.numeric(num.test["brasil"])
it2 <- it2 + as.numeric(num.test["trains"])
it3 <- it4 + 1
it4 <- it4 + as.numeric(num.test["trains"])
knn.dtm.tr[it1:it2,] <- df[it3:it4, 1:last.col]
knn.class.tr[it1:it2] <- df[it3:it4, last.col + 1]

it1 <- it1 + as.numeric(num.test["trains"])
it2 <- it2 + as.numeric(num.test["sad"])
it3 <- it4 + 1
it4 <- it4 + as.numeric(num.test["sad"])
knn.dtm.tr[it1:it2,] <- df[it3:it4, 1:last.col]
knn.class.tr[it1:it2] <- df[it3:it4, last.col + 1]

it1 <- it1 + as.numeric(num.test["sad"])
it2 <- it2 + as.numeric(num.test["thepiratebay"])
it3 <- it4 + 1
it4 <- it4 + as.numeric(num.test["thepiratebay"])
knn.dtm.tr[it1:it2,] <- df[it3:it4, 1:last.col]
knn.class.tr[it1:it2] <- df[it3:it4, last.col + 1]

#generating test data

knn.dtm.ts <- df[(as.numeric(num.train["cyberpunk"])          +
                  as.numeric(num.train["brasil"])             +
                  as.numeric(num.train["trains"])             +
                  as.numeric(num.train["sad"])                +
                  as.numeric(num.train["thepiratebay"])       +
                  1) : (as.numeric(num.train["cyberpunk"])    +
                        as.numeric(num.train["brasil"])       +
                        as.numeric(num.train["trains"])       +
                        as.numeric(num.train["sad"])          +
                        as.numeric(num.train["thepiratebay"]) +
                        as.numeric(num.test["cyberpunk"])     +
                        as.numeric(num.test["brasil"])        + 
                        as.numeric(num.test["trains"])        +
                        as.numeric(num.test["sad"])           +
                        as.numeric(num.test["thepiratebay"])
                  ), 1:last.col]

knn.class.ts <- df[(as.numeric(num.train["cyberpunk"])          +
                    as.numeric(num.train["brasil"])             +
                    as.numeric(num.train["trains"])             +
                    as.numeric(num.train["sad"])                +
                    as.numeric(num.train["thepiratebay"])       +
                    1) : (as.numeric(num.train["cyberpunk"])    +
                          as.numeric(num.train["brasil"])       +
                          as.numeric(num.train["trains"])       +
                          as.numeric(num.train["sad"])          +
                          as.numeric(num.train["thepiratebay"]) +
                          as.numeric(num.test["cyberpunk"])     +
                          as.numeric(num.test["brasil"])        + 
                          as.numeric(num.test["trains"])        +
                          as.numeric(num.test["sad"])           +
                          as.numeric(num.test["thepiratebay"])
                      ), last.col + 1]

knn.dtm.tr2 <- knn.dtm.tr

#add noise
for (i in 1:length(knn.dtm.tr2)){
  for (j in 1:length(knn.dtm.tr2[[i]])){
    knn.dtm.tr2[[i]][[j]] <- knn.dtm.tr2[[i]][[j]] + runif(1,0,0.001)
  }
}


knn.pred = knn(train = knn.dtm.tr2, test = knn.dtm.ts, cl = knn.class.tr, k = 1, l = 0, prob = T, use.all = F)

mat.conf <-table(knn.pred, knn.class.ts)
mat.conf







