
x = df %>% 
  group_by(ID) %>% 
  mutate(Visit = 1:n()) %>% 
  gather("reelin", "glucagon", "adiponectin", "obestatin" , "session", key = variable, value = number) %>% 
  unite(combi, variable, Visit) %>% 
  spread(combi, number)

colnames(x) = c("group","ID","id","adiponectin_V3","adiponectin_V10","glucagon_V3", "glucagon_V10","obestatin_V3","obestatin_V10","reelin_V3","reelin_V10", "Insulin_V3", "Insulin_V10","session_V3" ,"session_V10")    

f = merge(DATA, x, by = "ID", all=TRUE)

write_delim(f, 'data.tsv', delim = "\t")

insulin1 <- gather(df, session, insulin, c(Insulin_V3,Insulin_V10), factor_key=TRUE)
dft = select(insulin1, c(ID, session, insulin))
