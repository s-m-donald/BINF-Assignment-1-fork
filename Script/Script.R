# Assignment 1
# Version:  2023.09.0+463
# Author: Eric Bonk
# Assignment 3 edits coded by Sarah Donald (last edited: November 14, 2023). Contributions include creating edits to make the read-through easier, adding a new figure to compare number of records of each species for each genus. Edits for generalization were also made to improve the flexibility of the code. Minor edits were also made for overall improvement. 

#Libraries Used ----
#This section contains all the relevant packages used in this code.

#install.packages("tidyverse")
library(tidyverse) 

#install.packages("plotrix")
library(plotrix)

#install.packages("car")
library(car)

#install.packages("ggplot2")
library(ggplot2)

#install.packages("RgoogleMaps")
library(RgoogleMaps)

#install.packages("ggmap")
library(ggmap)

#install.packages("ggpubr")
library(ggpubr)

#install.packages("viridis")
library(viridis) 

# Load Data----
#Here is where data can be taken from BOLD. Change the link to compare other genera. 

Genus_1 <- read_tsv(file = "http://www.boldsystems.org/index.php/API_Public/combined?taxon=Oncorhynchus&format=tsv")
Genus_1_name <- "Oncorhynchus" # change the name to the genus of interest if needed.

Genus_2 <- read_tsv(file = "http://www.boldsystems.org/index.php/API_Public/combined?taxon=Lepomis&format=tsv")
Genus_2_name <- "Lepomis" # change the name to the genus of interest if needed.

# Preliminary filtering of data ----
# NA Values need to be removed. Due to the nature of the analysis only high quality and complete data will be used.For this assignment we care about the country, bins, and species.

# Remove values with no country data, bin data, and/or species data for both data sets.  

Genus_1 <- Genus_1 %>%
  filter(! country %in% c(NA)) %>%
  filter(! bin_uri %in% c(NA)) %>%
  filter(! species_name %in% c(NA))

Genus_2 <- Genus_2 %>%
  filter(! country %in% c(NA)) %>%
  filter(! bin_uri %in% c(NA)) %>%
  filter(! species_name %in% c(NA))


# Data Check----
# For this assignment we are working with the number of records and geological data
# We need to check to make sure there is not errors 

# Check to make sure both genera have at least 10 bins

length(unique(Genus_1$bin_uri))
length(unique(Genus_2$bin_uri))

# Check to make sure that species are actually species in the genus 

unique(Genus_1$species_name)
unique(Genus_2$species_name)

# For the geological data need to make sure the countries are actually countries 
# Determine the countries for each genus 

unique(Genus_1$country)

unique(Genus_2$country)


# Oncorhynchus (Genus_1) has "Exception - Culture" which needs to be removed

Genus_1<- Genus_1 %>% 
  filter(!country %in% c('Exception - Culture'))

# It is important to note that "Exception - Culture" was deliberately and critically removed now in order to ensure that both the records per species analysis and geographic analysis use the same data

# Number of records analysis----
# Filter data
# Determine the number of records per species 
Genus_1_simplified <- Genus_1 %>%
  group_by(species_name) %>%
  summarise(count = length(processid))

Genus_2_simplified<-Genus_2 %>%
  group_by(species_name) %>%
  summarise(count = length(processid))

# Summarization of key variables for analysis----
#Create a summary table of key statistics of each Genus
summary_Genus_1 <- c("Sum"= sum(Genus_1_simplified$count), "Mean" = mean(Genus_1_simplified$count), "Standard Error" = std.error(Genus_1_simplified$count), "Min" = min(Genus_1_simplified$count), "Max" = max(Genus_1_simplified$count))
summary_Genus_1

summary_Genus_2 <- c("Sum"= sum(Genus_2_simplified$count), "Mean" = mean(Genus_2_simplified$count), "Standard Error" = std.error(Genus_2_simplified$count), "Min" = min(Genus_2_simplified$count), "Max" = max(Genus_2_simplified$count))
summary_Genus_2

rm(summary_Genus_1)
rm(summary_Genus_2)

# Determine if there is a statistically significant difference----
# Test assumptions
shapiro.test(Genus_1_simplified$count)
shapiro.test(Genus_2_simplified$count)

# Levene test
leveneTest(Genus_1_simplified$count,Genus_1_simplified$species_name)
leveneTest(Genus_2_simplified$count,Genus_2_simplified$species_name)

# The Levene's test is NA due to there being only one replicate per species so in order to further assess the distribution of the data a histogram needs to be made 
hist(Genus_1_simplified$count) # Positive skew
hist(Genus_2_simplified$count) # Positive skew

# Data is Non-parametric so Wilcox test
wilcox.test(Genus_2_simplified$count, Genus_1_simplified$count)
# Statistically significant difference occurs 

# Make bar plot for the mean number of records per species for each genus----
# Make data frame to conform to ggplot requirements
records_per_species<-data.frame(count=c(Genus_2_simplified$count,Genus_1_simplified$count ),
                                Genus=c(rep(Genus_2_name, length(Genus_2_simplified$count)), 
                                        rep(Genus_1_name, length(Genus_1_simplified$count))))
# Plot 
ggplot(records_per_species, aes(x=factor(Genus), y=count)) +
  geom_bar(stat="summary", fill = "lightblue")+
  stat_summary(fun.data = mean_se,  
               geom = "errorbar") +
  labs(y="The Mean Number of Records per Species", x="Genus")+
  theme(axis.text.x = element_text(size=10,face = "bold"))+
  theme(axis.title = element_text(size = 10,face = "bold")) + 
  theme(panel.background = element_blank()) +
  ggtitle("Mean Number of Records per Species vs Genus") +
  theme(axis.ticks.length = unit(0.28,"cm"))
  

#Plot to break down record numbers by species.
plot_Genus_1 <- ggplot(data = Genus_1_simplified, aes(y = count, x = species_name)) +
  geom_bar(stat="identity", color = "purple", fill = "lavender") + 
  labs(x =" Genus 1 Species Name", y = " Number of Records") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(face = "bold")) +
  geom_hline(yintercept = 0) +
  theme(panel.background = element_blank()) +
  ggtitle("A.") + 
  geom_text(aes(label=count), vjust=1, color="black", size= 2)

plot_Genus_2 <- ggplot(data = Genus_2_simplified, aes(y = count, x = species_name)) +
  geom_bar(stat="identity", color = "darkgreen", fill = "lightgreen") + 
  labs(x =" Genus 2 Species Name", y = " Number of Records") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(face = "bold")) +
  geom_hline(yintercept = 0) +
  theme(panel.background = element_blank()) +
  ggtitle("B.") + 
  geom_text(aes(label=count), vjust=1, color="black", size= 2)

ggarrange(plot_Genus_1,plot_Genus_2, ncol =2)
 
#remove objects
rm(plot_Genus_1)
rm(plot_Genus_2)
rm(records_per_species)

# Geological analysis ----
# Determine contributing countries for each genus
countries_Genus_1 <- unique(Genus_1$country)
countries_Genus_2 <- unique(Genus_2$country)
# Filter data
# Determine the number of contributing countries per species 

Genus_1_simplified_geo<-Genus_1 %>%
  group_by(species_name) %>%
  summarise(count = length(unique(country)))
Genus_2_simplified_geo<- Genus_2 %>%
  group_by(species_name) %>%
  summarise(count = length(unique(country)))

# Summarization of key variables for analysis----
# Determine how many contries have contributed to each genus 
length(countries_Genus_1)
length(countries_Genus_2)
# Are there any countries shared between the 2 genera
intersect(countries_Genus_1,countries_Genus_2) # 11 Countries in common 
# Determine mean number of countries per species for each genus
mean(Genus_1_simplified_geo$count)
mean(Genus_2_simplified_geo$count)
# Determine standard error for the mean number of records for each genus 
std.error(Genus_1_simplified_geo$count)
std.error(Genus_2_simplified_geo$count)
# Determine range of number of countries for each genus 
range(Genus_1_simplified_geo$count)
range(Genus_2_simplified_geo$count)


# Determine if there is a statistically significant difference----
# Test assumptions
shapiro.test(Genus_2_simplified_geo$count)
shapiro.test(Genus_1_simplified_geo$count)
# Levene test
leveneTest(Genus_2_simplified_geo$count,Genus_2_simplified_geo$species_name)
leveneTest(Genus_1_simplified_geo$count,Genus_1_simplified_geo$species_name)
# The Levene's test is NA due to there being only one replicate per species so in order to further assess the distribution of the data a histogram needs to be made 
hist(Genus_1_simplified_geo$count) # Positive skew
hist(Genus_2_simplified_geo$count) # Positive skew
# Data is Non-parametric so Wilcox test
wilcox.test(Genus_2_simplified_geo$count, Genus_1_simplified_geo$count)
# Statistically significant difference occurs 
# Make map of countries that have contributed to data----
# In order to increase the readability of the map the coordinates in the Bold Data sets can not be used as each country would have many data points in slightly different locations 
# Need to use a central coordinate for each country 
# Must retrieve general country coordinates from the function map_data
country.maps <- map_data("world")
# Filter the data frame for the countries needed for each genus 
country_cord_Genus_1<- country.maps%>% filter(region %in% c(countries_Genus_1))
country_cord_Genus_2<- country.maps%>% filter(region %in% c(countries_Genus_2))
# These coordinates are the border coordinates so we need to take the mean of the lat and long for each country to get a roughly central coordinate
country_cord_Genus_1<-country_cord_Genus_1%>%
  group_by(region) %>%
  summarise(long = mean(long), lat = mean(lat)) %>%
  rename(Country=region) #Change name of region column for convenience.
country_cord_Genus_2<-country_cord_Genus_2%>%
  group_by(region) %>%
  summarise(long = mean(long), lat = mean(lat)) %>%
  rename(Country=region) #Change name of region column for convenience.


# Load base map
# Note: Depending on the computer and the experience someone has with the get_map function, an initial attempt to load a world map using this function may not work. The function get_map archives map tiles as you use them and since I use the package frequently I have many tiles already archived. The package often won't run on a map this size if there are no archives. What you need to do is start with a smaller range of coordinates and slowly increase the range of coordinates. For me I simply had to use these lines of code:
# base = get_map(location=c(-180,-85,180,85), zoom=3, maptype="terrain-background")
# map1 = ggmap(base)
# But in order to make sure the base map loads properly I have uploaded the ggmap file to my GitHub. For convenience I will walk through how to access the file. Note: This file was created by me using the code in lines 156 and 157 and then using the code save(map1, file = "map.RData"). I then uploaded and published the file on my github.
load(url("https://github.com/EricABonk/BINF-Assignment-1/releases/download/v1.0.0/map.RData"))
map1
# Check to make sure base map has loaded correctly and zoom is at an appropriate level
map1

# Apply genus data to base map for each genus

map_Genus_1<-map1 + geom_point(data=country_cord_Genus_1, aes(x=long, y=lat, colour= Country), shape=20, size=2)+
  scale_color_viridis(discrete = TRUE,option = "H")+
  labs(x="Latitude (\u00B0)", y="Longitude (\u00B0)") + 
  theme_bw() + theme(axis.text = element_text(size = rel(0.75),face = "bold"), 
                     axis.text.x = element_text(angle=45, vjust=0.5,face = "bold"),
                     axis.title =  element_text(face = "bold"))+
  theme(legend.text =element_text(size = 9,face = "bold"))+
  theme(legend.key.size = unit(.2, 'cm')) + 
  theme(legend.title = element_text(face = "bold"))+
  guides(colour = guide_legend(ncol = 1))

map_Genus_2<-map1 + geom_point(data=country_cord_Genus_2, aes(x=long, y=lat,colour=Country), shape=20, size=2)+
  scale_color_viridis(discrete = TRUE,option = "H")+
  labs(x="Latitude (\u00B0)", y="Longitude (\u00B0)") + 
  theme_bw() + theme(axis.text = element_text(size = rel(0.75),face = "bold"), 
                     axis.text.x = element_text(angle=45, vjust=0.5,face = "bold"),
                     axis.title =  element_text(face = "bold"))+
  theme(legend.text =element_text(size = 9,face = "bold"))+
  theme(legend.key.size = unit(.2, 'cm')) + 
  theme(legend.title = element_text(face = "bold"))


# Place the two maps side by side 
ggarrange(map_Genus_1,map_Genus_2, ncol=1,labels = c("A", "B"),font.label = list(size=10))

#remove objects
rm(map_Genus_1)
rm(map_Genus_2)
rm(country_cord_Genus_1)
rm(country_cord_Genus_2)
rm(countries_Genus_1)
rm(countries_Genus_2)
rm(Genus_1_simplified_geo)
rm(Genus_1_simplified)
rm(Genus_2_simplified)
rm(Genus_2_simplified_geo)
rm(Genus_2_name)
rm(Genus_1_name)
rm(map1)
rm(Genus_1)
rm(Genus_2)
rm(country.maps)
