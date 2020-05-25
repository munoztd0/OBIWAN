function var = randomizeList2(var)
randomIndex = randperm(length(var.CheckCSs)); 
var.CheckCSs = var.CheckCSs(randomIndex);
var.CheckCond = var.CheckCond(randomIndex);  
end