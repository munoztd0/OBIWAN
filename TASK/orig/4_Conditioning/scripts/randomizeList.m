function var = randomizeList(var)
randomIndex = randperm(length(var.PavCSs)); 
var.PavCSs = var.PavCSs(randomIndex);
var.PavCond = var.PavCond(randomIndex);
var.PavTrig = var.PavTrig(randomIndex);
var.PavStim = var.PavStim(randomIndex);     
end