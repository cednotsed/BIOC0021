rm(list = ls())
setwd('~/git_repos/BIOC0021/workspace')
require(data.table); require(tidyverse); require(ggplot2); require("ggsci")

df <- fread("data/mutation_rates2.parsed.csv", strip.white = T, encoding = "UTF-8")

plot_df <- df %>% mutate(log_rate = log(mutation_rate), 
              anellovirus = ifelse(family == "Anelloviridae", "yes", "no"))


annot_df <- plot_df %>% 
  filter(family == "Anelloviridae") %>%
  rename(virus_name = "virus name")
  
ggplot() +
  geom_point(data = plot_df, aes(x = type, y = log_rate, color = type)) +
  labs(x = "Genome type", y = "lg(subst. rate)") +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 30, hjust = 1)) +
  geom_point(data = annot_df, aes(x = type, y = log_rate),
             color = "black",
             shape = 18,
             size = 2.5)
  # geom_text(data = annot_df, 
  #           aes(x = type, y = log_rate, label = virus_name),
  #           color = "black",
  #           hjust = 1.4,
  #           size = 2)
  
ggsave("results/mutation_rates.png", dpi = 600, width = 6, height = 6)

