rm(list = ls())
setwd('~/git_repos/BIOC0021/workspace')
require(data.table); require(tidyverse); require(ggplot2); require("sf"); require("rnaturalearth"); require("rnaturalearthdata"); require("ggsci")

# install.packages(c("cowplot", "googleway", "ggplot2", "ggrepel",
#                   "ggspatial", "libwgeom", "sf", "rnaturalearth",
#                   "rnaturalearthdata"))

plot_df <- fread("data/prevalence_estimates.csv")
plot_df <- plot_df %>%
  select(-prevalence) %>%
  pivot_longer(c(ttv, ttmv, ttmdv), names_to = "virus", values_to = "prevalence") %>%
  mutate(virus = toupper(virus))

plot_df$virus <- factor(plot_df$virus, levels = c("TTV", "TTMV", "TTMDV"))

plot_df1 <- plot_df %>%
  filter(!is.na(prevalence), virus == "TTV")

plot_df2 <- plot_df %>%
  filter(!is.na(prevalence), virus == "TTMV")

plot_df3 <- plot_df %>%
  filter(!is.na(prevalence), virus == "TTMDV")

# Plot world map
# theme_set(theme_dark())
world <- ne_countries(scale = "medium", returnclass = "sf")
fsize <- 14

plt1 <- ggplot(data = world) +
  geom_sf(fill = "#003366") +
  xlab("Longitude") + ylab("Latitude") +
  geom_point(data = plot_df1, 
             aes(x = long, y = lat, fill = prevalence), 
             size = 4,
             shape = 23) +
  scale_fill_gradient(low = "grey", high = "red") +
  labs(fill = "Prevalence (%)") +
  theme(plot.title = element_text(face = 'bold', hjust = 0.5, size = fsize + 2),
        plot.subtitle = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = fsize),
        legend.text = element_text(size = fsize),
        panel.background = element_rect(fill = "#99CCCC"),
        panel.grid = element_blank(),
        legend.position = "top")

# TTMV
plt2 <- ggplot(data = world) +
  geom_sf(fill = "#003366") +
  xlab("Longitude") + ylab("Latitude") +
  geom_point(data = plot_df2, 
             aes(x = long, y = lat, fill = prevalence), 
             size = 4,
             shape = 23) +
  scale_fill_gradient(low = "grey", high = "red") +
  labs(fill = "Prevalence (%)") +
  theme(plot.title = element_text(face = 'bold', hjust = 0.5, size = fsize + 2),
        plot.subtitle = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = fsize),
        legend.text = element_text(size = fsize),
        panel.background = element_rect(fill = "#99CCCC"),
        panel.grid = element_blank(),
        legend.position = "top")

# TTMDV
plt3 <- ggplot(data = world) +
  geom_sf(fill = "#003366") +
  xlab("Longitude") + ylab("Latitude") +
  geom_point(data = plot_df3, 
             aes(x = long, y = lat, fill = prevalence), 
             size = 4,
             shape = 23) +
  scale_fill_gradient(low = "grey", high = "red") +
  labs(fill = "Prevalence (%)") +
  theme(plot.title = element_text(face = 'bold', hjust = 0.5, size = fsize + 2),
        plot.subtitle = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = fsize),
        legend.text = element_text(size = fsize),
        panel.background = element_rect(fill = "#99CCCC"),
        panel.grid = element_blank(),
        legend.position = "top")

plt4 <- ggplot(plot_df, aes(x = virus, y = prevalence, fill = virus)) + 
  geom_boxplot(alpha = 0.5, fill = c("steelblue", "firebrick", "burlywood")) +
  theme_classic() +
  geom_point(color = "black", alpha = 0.3) +
  labs(x = "Virus", y = "Prevalence (%)") +
  theme(legend.position = "none")

prev_plot <- ggpubr::ggarrange(plt1, plt2, plt3, 
                  ncol = 3, nrow = 1,
                  common.legend = T, legend = "none")

ggsave("results/prevalence_map.png", plot = prev_plot, dpi = 600, height = 2, width = 9)
ggsave("results/boxplot.png", plot = plt4, dpi = 600, height = 4, width = 9)

