    
    A =strcmp(data.odorLabel,'empty');
    B = strcmp(data.odorLabel,'chocolate');
    data.odorLabel2 = categorical(zeros(1,data.Trial(end))'+ A + A + B)
    data.odorLabel2 = mergecats(data.odorLabel2,'2','empty')
    data.odorLabel2 = mergecats(data.odorLabel2,'1','chocolate')
    data.odorLabel2 = cellstr(mergecats(data.odorLabel2,'0','aladinate'))
    
  