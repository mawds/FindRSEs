# install.packages("xml2")
# install.packages("tm")
# install.packages("wordcloud")

require(xml2)
require(tm)
require(magrittr)
require(SnowballC)
require(wordcloud)
library(dplyr)
library(ggplot2)

xml<- read_xml("C:/Users/Tom/Desktop/xmlfile/researchsoftwareengineersassociation.wordpress.2018-03-19.xml")

words<- xml %>% xml_text(trim=TRUE)

words<- strsplit(words, " ") 

words<- words %>% tolower() %>% removeWords( c(words=stopwords(kind="en"),"will")) %>%
  removeNumbers() %>% removePunctuation() %>% strsplit(" ") %>% unlist() %>%
  stemDocument()

words<- words[nchar(words)<12 & nchar(words)>1]

set.seed(20)
wordcloud(words, min.freq = 100, max.words = 1000, colors=c("red","blue","green"))

#### Twitter bio descriptions 
# twitter bios created by using the tweetr - rsenetwork and 250 followers. 

load("C:/Users/Tom/Desktop/xmlfile/RSEFollows.RData")

bios<-rse_follows_data$description

bios<- bios %>% unlist()
bios<- strsplit(bios, " ")

bios.words<-unlist(bios)

bios.words<-iconv(bios.words, from="UTF-8", to="ASCII")

bios.words<- bios.words %>% tolower() %>% removeWords( c(words=stopwords(kind="en"),"will")) %>%
  removeNumbers() %>% removePunctuation() %>% strsplit(" ") %>% unlist() %>%
  stemDocument()

barplot(table(bios.words)[table(bios.words)>20], las=2)

par(mfrow=c(1,2))
set.seed(20)
wordcloud(words, min.freq = 100, max.words = 1000, colors=c("red","blue","green"),
          main="RSE Advert Wordcloud")
set.seed(20)
wordcloud(bios.words, min.freq = 20, max.words = 100, colors=c("red","blue","green"),
          main="Twitter data sci/RSE")

combinedWords <- rbind(data.frame(source="jobs", word=words),
                       data.frame(source="twitter", word=bios.words))

combinedWords %<>% group_by(source, word) %>% 
  summarise(freq=n()) %>%  ungroup() 

totals <- combinedWords %>% group_by(source) %>% summarise(total=n())

combinedWords %<>%  full_join(totals, by="source") %>% 
  mutate(relfreq = as.numeric(freq)/as.numeric(total))


combinedrel <- combinedWords %>% group_by(word) %>% 
  summarise(avgrel = mean(relfreq, na.rm=TRUE)) %>% 
  arrange(desc(avgrel))

# levels(combinedWords$word) <- combinedrel$word
combinedWords$ordered <- factor(as.character(combinedWords$word), 
                                levels= combinedrel$word)

combinedWords %>% 
   mutate(relfreq = ifelse(source == "jobs", -relfreq, relfreq)) %>% 
  filter(word %in% combinedrel$word[1:50]) %>% 
  filter(word != "NA") %>% 
  ggplot(aes(x=ordered, y=relfreq, group=source, fill = source)) + geom_col() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(y="relative frequency") + coord_flip()


words.table<- table(words)

bios.words.table<- table(bios.words)

bios.words.table<-bios.words.table-bios.words.table*2

par(mfrow=c(2,1))
barplot(sort(words.table[words.table>50]), las=2)
barplot(sort(bios.words.table)[bios.words.table<(-50)], las=2)
