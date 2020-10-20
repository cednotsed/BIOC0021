rm(list = ls())
setwd('~/git_repos/BIOC0021/workspace/')
require(data.table); require(tidyverse); require(ggplot2); require("sf"); require("rnaturalearth"); require("rnaturalearthdata"); require("ggsci")

# install.packages(c("cowplot", "googleway", "ggplot2", "ggrepel",
#                   "ggspatial", "libwgeom", "sf", "rnaturalearth",
#                   "rnaturalearthdata"))

plot_df <- fread("data/prevalence_estimates.csv")
View(plot_df)
# Plot world map
# theme_set(theme_dark())
world <- ne_countries(scale = "medium", returnclass = "sf")
fsize <- 14
ggplot(data = world) +
  geom_sf(fill = "#003366") +
  xlab("Longitude") + ylab("Latitude") +
  geom_point(data = plot_df, 
             aes(x = long, y = lat, fill = ttv), 
             size = 4,
             shape = 23) +
  scale_fill_gradient(low = "grey", high = "red") +
  labs(fill = "TTV Prevalence (%)") +
  theme(plot.title = element_text(face = 'bold', hjust = 0.5, size = fsize + 2),
        plot.subtitle = element_blank(),
        axis.title = element_text(face = 'bold', size = fsize),
        legend.title = element_text(size = fsize),
        legend.text = element_text(size = fsize),
        panel.background = element_rect(fill = "#99CCCC"),
        panel.grid = element_blank())

ggsave("results/prevalence_map.png", dpi = "retina", height = 5, width = 10)



