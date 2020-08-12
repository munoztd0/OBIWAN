function resetCSnames(var)

if var.list == 1;
    movefile('CSplus.jpg', 'yellow.jpg');
    movefile ('CSminu.jpg', 'green.jpg');
    movefile ('Baseli.jpg', 'red.jpg');
    
elseif var.list == 2;
    movefile('CSplus.jpg', 'yellow.jpg');
    movefile ('Baseli.jpg', 'green.jpg');
    movefile ('CSminu.jpg', 'red.jpg');
    
elseif var.list == 3;
    movefile('CSminu.jpg', 'yellow.jpg');
    movefile ('CSplus.jpg', 'green.jpg');
    movefile ('Baseli.jpg', 'red.jpg');
    
elseif var.list == 4;
    movefile('CSminu.jpg', 'yellow.jpg');
    movefile ('Baseli.jpg', 'green.jpg');
    movefile ('CSplus.jpg', 'red.jpg');
    
elseif var.list == 5;
    movefile('Baseli.jpg', 'yellow.jpg');
    movefile ('CSplus.jpg', 'green.jpg');
    movefile ('CSminu.jpg', 'red.jpg');
    
elseif var.list == 6;
    movefile('Baseli.jpg', 'yellow.jpg');
    movefile ('CSminu.jpg', 'green.jpg');
    movefile ('CSplus.jpg', 'red.jpg');
    
end