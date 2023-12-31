---
  title: "Airbnb Analysis"
output:
  html_document: default
pdf_document: default
---
  
  # Description of Dataset
  
  Analyze the data on airbnb listings in New York City. The data set includes details about each listing such as price, type of lodging, the minimum number of nights guests are required to stay, and more. Below is a summary of the information and metrics for the airbnb listings in New York City:
  
  ## Table 
  
  ```{r}
varsdescription <- matrix(c("VARIABLE EXPLANATION", "Listing ID", "name of the listing", "host ID", "name of the host", "borough", "area", "latitude coordinates", "longitude coordinates","listing space type", "price in dollars", "minimum number of nights", "number of reviews", "latest review", "number of reviews per month", "number of listings per host", "number of days when listing is available for book per year"), ncol=1)
colnames(varsdescription) <- c("")
rownames(varsdescription) <- c("VARIABLE NAME","id", "name", "host_id", "host_name", "neighbourhood_group", "neighbourhood", "latitude", "longtitude", "room_type", "price", "minimu,_nights", "number_of_reviews", "last_review", "reviews_per_month", "calculated_host_listings_count", "availability_365")
varsdescription.table <- as.table(varsdescription)
varsdescription.table
```

# Description of Motivation and Interest

I decided to focus on price and reviews for the airbnb data because I believe these are two of the most important aspects that people consider when renting airbnbs. Customers place a lot of value on reviews in order to judge the quality of an airbnb, and price is important in order for people to be able to properly budget for their trip. In particular, many low income people have used airbnbs before since they are often more affordable than hotels. That is why I am interested in finding a way to find affordable airbnbs that are still of good quality.

# Import image 

```{r figurename, echo=FALSE, fig.cap="my caption", out.width = '90%'}
knitr::include_graphics("New_York_City_.png")
```

# Set up 

```{r}
library(tidyverse)
library(gapminder)
airbnb0 <- read.csv("AB_NYC_2019.csv")

```

## Research Question 1

Of the airbnbs that have been reviewed in 2019, which neighborhood group has the most average reviews per month? Within this neighborhood group, what is the relationship between price and reviews per month? How does this neighbourhood group compare to all other neighbourhood groups?
  
  
  ### Cleaning Data for Research Question 1 
  
  1. Remove unnecessary columns, create new data frame  
2. Filter out unnecessary rows 

```{r}
airbnb1 <- airbnb0 %>%
  select(neighbourhood_group, neighbourhood, room_type, price, last_review, number_of_reviews, reviews_per_month) %>% #select relevant columns 
  filter(price > 0) %>% #filter out prices that are 0 
  na.omit() %>% #filter out the rows that contain NA or missing values 
  filter(grepl('2019', last_review)) #select airbnbs that are last reviewed in 2019  
```


## Code for Question 1 

1. Of the airbnbs that have been reviewed in 2019, which neighborhood group has the most average reviews per month?
  
  ```{r}
airbnb1 %>%
  group_by(neighbourhood_group) %>%
  summarise(average_reviews = mean(reviews_per_month)) %>%
  arrange(desc(average_reviews))
```
ANSWER: Queens is the neighborhood group with the most average reviews per month. 

2. What is the relationship between price and reviews per month in  Queens?
  
  ```{r}
# Make new dataset for log(price) and log(reviews per month) in Queens to control for skew
queens <-
  airbnb1 %>%
  filter(neighbourhood_group == "Queens") %>%
  mutate(log_price = log(price)) %>%
  mutate(log_reviews = log(reviews_per_month))

```

```{r}
# Creating the gg scatter plot comparing log(reviews) and log(price) for Queens

ggplot(queens, aes(log_reviews, log_price)) +
  geom_point()+
  geom_smooth()+ 
  facet_wrap(~neighbourhood_group)+ 
  labs(x = "Log of Reviews Per Month", y = "Log of Price", title = "Figure 1: Log(Reviews Per Month) vs. Log(Price) for Queens")
```

Figure 1: This figure shows that there is no clear relationship between the average number of reviews per month and the price of the airbnbs in Queens 

3. How does the relationship found for Queens compare to the other neighbourhood groups?
  
  ```{r}
# Make new dataset for log(price) and log(reviews per month) in each neighbourhood group to control for skew

airbnb_allgroups<-
  airbnb1 %>%
  mutate(log_price = log(price)) %>%
  mutate(log_reviews = log(reviews_per_month))
```

```{r}
# Creating the gg scatter plot comparing the neighbourhood groups by faceting 
ggplot(airbnb_allgroups, aes(log_reviews, log_price)) +
  geom_point()+
  geom_smooth()+ 
  facet_wrap(~neighbourhood_group)
```

Figure 2: Compared to the other neighborhood groups, the relationship between the reviews per month and the price in Queens is the same for the other neighbourhood groups. In other words, none of the neighbourhood groups show a correlation between the number of reviews received per month and the price of the air bnb. 


## Research Question 2 

What is the association between price and the number of listings an airbnb host has, controlling for neighborhood group and room type?
  
  ### Cleaning Data for Research Question 2 
  
  ```{r}
airbnb0$numListings <- factor(NA, levels = c("1 listing", "Multiple listings")) #create new variable
airbnb0$numListings[airbnb0$calculated_host_listings_count == 1] <- "1 listing" 
airbnb0$numListings[airbnb0$calculated_host_listings_count > 1] <- "Multiple listings"

airbnb2 <- airbnb0 %>%
  select(neighbourhood_group, room_type, price, numListings) %>% #select relevant columns 
  filter(price > 0) %>% #filter out prices that are 0 
  na.omit()#filter out the rows that contain NA or missing values 

View(airbnb2)
```

### Research Question 2 Code

```{r}
## General Scatter Plot Try out for Entire Home/apt

airbnb2 %>% 
  filter(room_type == "Entire home/apt") %>%
  ggplot(aes(x = numListings, y = price)) + 
  geom_point(aes(size = 0.1, alpha = 0.01, color = neighbourhood_group)) +
  facet_wrap(~neighbourhood_group, scales = "free")
```

Hard to read, so I tried to make a box plot. 

```{r}
## General Box plot try out for entire home/apt

airbnb2 %>% 
  filter(room_type == "Entire home/apt") %>%
  ggplot(x = numListings, y = price)+
  geom_boxplot(aes(x = numListings, y = price, size = 1, alpha = 0.01, color = neighbourhood_group)) +
  ggtitle("Relationship between price and numListing for entire home/apt")+
  facet_wrap(~neighbourhood_group, scales = "free")
```

Still hard to read, so chose cutoff points for better data visualization. The rationale behind choosing the price limit of 400 dollars for entire home/apt, 200 for private room, and 150 for shared room is to better visualize the box plot so that the median and Quartile lines does not fall into the top or bottom edges. 


```{r}
## Figure 3: Entire home/apt boxplot - zoomed in

airbnb2 %>% 
  filter(room_type == "Entire home/apt") %>%
  ggplot(aes(numListings, price, color = neighbourhood_group)) +
  geom_boxplot() + coord_cartesian(ylim=c(0, 400)) + #zoomed in 
  ggtitle("Figure 3: Relationship between price and numListing for entire home/apt") +
  facet_wrap(~neighbourhood_group, scales = "free")
```
Figure 3: For entire home/apartment, on average, multiple listings from the host is associated with a higher price compared to hosts with a single listing. This is shown by Q2, Q3 and median of "Multiple listings" being higher than "1 listing" in every neighbourhood group. This may be due to the fact that hosts with multiple listings rely more on airbnb renting as a primary source of income. Therefore, the quality of the homes will be greater, and thus more expensive to rent.

```{r}
## Figure 4: Private room - zoomed in

airbnb2 %>% 
  filter(room_type == "Private room") %>%
  ggplot(aes(numListings, price, color = neighbourhood_group))+
  geom_boxplot() + coord_cartesian(ylim=c(0, 200)) + #zoomed in 
  ggtitle("Figure 4: Relationship between price and numListing for private room")+
  facet_wrap(~neighbourhood_group, scales = "free")
```

Figure 4: However, for private rooms 1 listing generally correlates with higher price in all neighbourhood group except for Manhattan. Private rooms in Manhattan have about the same price in Q2, Q3 and median for both. This trend is opposite from renting the entire home/apartment. Renters choose private homes over the entire apartment because they want the cheaper option; hosts with multiple listings (and rely more heavily on renting for income) will want to appeal to this frugal drive in order to sell more rooms. Therefore, the prices of rooms whose hosts have multiple listings are generally lower than hosts with one listing. This trend is not seen in Manhattan because Manhattan is known to be an expensive city, so there is no discrepancy between prices.

```{r}
## Figure 5: Shared room - zoomed in boxplot

airbnb2 %>% 
  filter(room_type == "Shared room") %>%
  ggplot(aes(numListings, price, color = neighbourhood_group))+
  geom_boxplot() + coord_cartesian(ylim=c(0, 150)) + #zoomed in 
  ggtitle("Relationship between price and numListing for shared room")+
  facet_wrap(~neighbourhood_group, scales = "free")
```

Figure 5: For shared rooms, 1 listing generally correlates with a higher price in all regions except for Staten Island where there is not enough data. This is consistent with the trend seen for private rooms: hosts with multiple listings are appealing to their audience who is looking for the most afforable housing. 


# Final interpretation of results and data visualizations

From research question 1, I found that Queens has the most average reviews per month. This is helpful for people who are looking for validation from other customers when choosing their airbnbs, since they have more opinions from prior customers to inform their decision. I also found that there is no relationship between the average number of reviews per month and the price of the airbnb’s in both Queens and the other four neighborhood groups. I would infer that this is because even though an airbnb may have more reviews, the reviews may be a mixture of qualities and not necessarily all good reviews, which is why reviews and price may not be related.

From research question 2, I learned that if you are looking to rent a more affordable room in NYC, you should search for rooms that have a host with multiple listings to get a cheaper price. Specifically, private and shared rooms are generally more affordable if the host has other listings. But if you are looking to rent an entire home/apartment, hosts with only one listing are slightly cheaper.

