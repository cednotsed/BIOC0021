setwd("~/../Desktop/year_3/BIOC0021/workspace")
require(litsearchr)
require(igraph)
naiveimport <- litsearchr::import_results(directory = "database_files/anelloviridae_anellovirus/", 
                                          verbose = TRUE)

naiveresults <-
  litsearchr::remove_duplicates(naiveimport, field = "title", method = "string_osa")

rakedkeywords <-
  litsearchr::extract_terms(
    text = paste(naiveresults$title, naiveresults$abstract),
    method = "fakerake",
    min_freq = 2,
    ngrams = TRUE,
    min_n = 2,
    language = "English"
  )
#> Loading required namespace: stopwords

taggedkeywords <-
  litsearchr::extract_terms(
    keywords = naiveresults$keywords,
    method = "tagged",
    min_freq = 5,
    ngrams = TRUE,
    min_n = 1,
    max_n = 2,
    language = "English"
  )

all_keywords <- unique(append(taggedkeywords, rakedkeywords))

naivedfm <-
  litsearchr::create_dfm(
    elements = paste(naiveresults$title, naiveresults$abstract),
    features = all_keywords
  )

naivegraph <-
  litsearchr::create_network(
    search_dfm = as.matrix(naivedfm),
    min_studies = 3,
    min_occ = 10
  )

cutoff <-
  litsearchr::find_cutoff(
    naivegraph,
    # method = "changepoint",
    method = "cumulative",
    percent = 0.80,
    imp_method = "strength"
  )

reducedgraph <-
  litsearchr::reduce_graph(naivegraph, cutoff_strength = cutoff[1])

searchterms <- litsearchr::get_keywords(reducedgraph)
print(quantile(E(reducedgraph)$weight, c(0.75, 0.90, 0.99)))

t <- 100
print(sum(E(reducedgraph)$weight >= t))

to_remove <- as_ids(E(reducedgraph)[E(reducedgraph)$weight < t])
g <- delete_edges(reducedgraph, to_remove)
bad.vs <- V(g)[degree(g) == 0]
g <- delete.vertices(g, bad.vs)

plot(g, 
     vertex.size = 3,
     vertex.frame.color = NA,
     layout = layout_nicely(g), 
     edge.width = E(g)$weight/20,
     label.cex = 0.5)


