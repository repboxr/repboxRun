library(ggplot2)
ggplot(dat, aes(x=x1,y=y)) +
  geom_point() +
  geom_smooth()
