function [lineartrend] = getLinearTrend(inputdata) 

    
    x = 1:length(inputdata);
    x = x';
    validData =~isnan(inputdata); 
    y1 = inputdata(validData);
    x1 = x(validData);
    % plot(x1,y1) 
    P = polyfit(x1,y1,1);
    lineartrend = P(1)*x+P(2);
    
    % plot(x,inputdata)
    % hold on;
    % plot(x,lineartrend);